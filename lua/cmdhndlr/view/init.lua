local Layout = require("cmdhndlr.view.layout").Layout
local cursorlib = require("cmdhndlr.lib.cursor")

local M = {}

local View = {}
View.__index = View
M.View = View

function View.open(working_dir, layout_opts)
  vim.validate({working_dir = {working_dir, "table"}, layout_opts = {layout_opts, "table", true}})
  layout_opts = layout_opts or {type = "horizontal"}

  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.bo[bufnr].filetype = "cmdhndlr"
  Layout.new(layout_opts):open(bufnr)
  working_dir:set_current()

  local tbl = {bufnr = bufnr, _window_id = vim.api.nvim_get_current_win()}
  return setmetatable(tbl, View)
end

function View.set_lines(self, output)
  vim.validate({output = {output, "string", true}})
  if output == nil then
    return
  end
  vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, true, vim.split(output, "\n", true))
end

function View.cursor_to_bottom(self)
  cursorlib.to_bottom(self.bufnr, self._window_id)
end

return M
