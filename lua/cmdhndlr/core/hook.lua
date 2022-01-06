local M = {}

local Hooks = {}
Hooks.__index = Hooks
M.Hooks = Hooks

function Hooks.new(on_success, on_failure)
  vim.validate({
    on_success = { on_success, "function", true },
    on_failure = { on_failure, "function", true },
  })
  local tbl = {
    success = on_success or function() end,
    failure = on_failure or function() end,
  }
  return setmetatable(tbl, Hooks)
end

function Hooks.from(raw_hooks, default)
  vim.validate({ raw_hooks = { raw_hooks, "table", true }, default = { default, "table", true } })
  raw_hooks = raw_hooks or {}
  default = default or {}
  local hooks = vim.tbl_extend("force", default, raw_hooks)
  return Hooks.new(hooks.success, hooks.failure)
end

function Hooks.info_factory()
  local start_time = vim.loop.now()
  return function()
    return { elapsed_ms = vim.loop.now() - start_time }
  end
end

return M
