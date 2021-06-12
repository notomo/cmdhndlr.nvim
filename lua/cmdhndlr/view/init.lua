local Layout = require("cmdhndlr.view.layout").Layout
local cursorlib = require("cmdhndlr.lib.cursor")

local M = {}

local View = {}
View.__index = View
M.View = View

function View.open(result, working_dir, layout_opts)
  vim.validate({
    result = {result, "table"},
    working_dir = {working_dir, "table"},
    layout_opts = {layout_opts, "table", true},
  })
  layout_opts = layout_opts or {type = "horizontal"}

  local bufnr = result.bufnr
  vim.bo[bufnr].filetype = "cmdhndlr"
  Layout.new(layout_opts):open(bufnr)
  working_dir:set_current()

  local tbl = {_bufnr = bufnr, _window_id = vim.api.nvim_get_current_win()}
  local self = setmetatable(tbl, View)

  self:_set_lines(result.output)

  return self
end

function View._set_lines(self, output)
  vim.validate({output = {output, "string", true}})
  if output then
    vim.bo[self._bufnr].modifiable = true
    vim.api.nvim_buf_set_lines(self._bufnr, 0, -1, true, vim.split(output, "\n", true))
    vim.bo[self._bufnr].modifiable = false
  end
  cursorlib.to_bottom(self._bufnr, self._window_id)
end

return M
