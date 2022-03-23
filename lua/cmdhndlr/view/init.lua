local Layout = require("cmdhndlr.view.layout").Layout

local M = {}
M.__index = M

function M.open(result, working_dir, layout_opts)
  vim.validate({
    result = { result, "table" },
    working_dir = { working_dir, "table" },
    layout_opts = { layout_opts, "table" },
  })

  local bufnr = result.bufnr
  vim.bo[bufnr].filetype = "cmdhndlr"
  Layout.new(layout_opts):open(bufnr)
  working_dir:set_current()

  local window_id = vim.api.nvim_get_current_win()
  local tbl = { _bufnr = bufnr, _window_id = window_id }
  return setmetatable(tbl, M)
end

return M
