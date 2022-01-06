local M = {}

local ExecuteScope = {}
ExecuteScope.__index = ExecuteScope
M.ExecuteScope = ExecuteScope

function ExecuteScope.new(scope_type)
  vim.validate({ scope_type = { scope_type, "string", true } })

  local cursor
  if scope_type == "cursor" then
    cursor = vim.api.nvim_win_get_cursor(0)
  end

  local tbl = { _type = scope_type, cursor = cursor }
  return setmetatable(tbl, ExecuteScope)
end

return M
