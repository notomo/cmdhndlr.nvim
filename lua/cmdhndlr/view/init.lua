local Layout = require("cmdhndlr.view.layout")

local M = {}
M.__index = M

function M.open(bufnr, working_dir, layout_opts)
  vim.validate({
    bufnr = { bufnr, "number" },
    working_dir = { working_dir, "table" },
    layout_opts = { layout_opts, "table" },
  })

  vim.schedule(function()
    vim.cmd.startinsert({ bang = true })
  end)

  vim.bo[bufnr].filetype = "cmdhndlr"
  Layout.new(layout_opts):open(bufnr)
  working_dir:set_current()

  local window_id = vim.api.nvim_get_current_win()
  local tbl = { _bufnr = bufnr, _window_id = window_id }
  return setmetatable(tbl, M)
end

return M
