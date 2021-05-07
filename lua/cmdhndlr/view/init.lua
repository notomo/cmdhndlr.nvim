local cursorlib = require("cmdhndlr.lib.cursor")

local M = {}

local View = {}
View.__index = View
M.View = View

function View.open()
  local bufnr = vim.api.nvim_create_buf(false, true)

  -- TODO
  vim.cmd("botright split")
  vim.cmd("buffer " .. bufnr)

  local tbl = {_bufnr = bufnr, _window_id = vim.api.nvim_get_current_win()}
  return setmetatable(tbl, View)
end

function View.set_lines(self, output)
  vim.validate({output = {output, "string", true}})
  if output == nil then
    return
  end
  vim.api.nvim_buf_set_lines(self._bufnr, 0, -1, true, vim.split(output, "\n", true))
end

function View.cursor_to_bottom(self)
  cursorlib.to_bottom(self._bufnr, self._window_id)
end

return M
