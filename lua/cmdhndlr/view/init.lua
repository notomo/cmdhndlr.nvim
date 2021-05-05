local M = {}

local View = {}
View.__index = View
M.View = View

function View.open()
  local bufnr = vim.api.nvim_create_buf(false, true)

  -- TODO
  vim.cmd("botright split")
  vim.cmd("buffer " .. bufnr)

  local tbl = {_bufnr = bufnr}
  return setmetatable(tbl, View)
end

return M
