local M = {}

local Hooks = {}
Hooks.__index = Hooks
M.Hooks = Hooks

function Hooks.new(on_success, on_failure)
  vim.validate({
    on_success = {on_success, "function", true},
    on_failure = {on_failure, "function", true},
  })
  local tbl = {
    success = on_success or function()
    end,
    failure = on_failure or function()
    end,
  }
  return setmetatable(tbl, Hooks)
end

return M
