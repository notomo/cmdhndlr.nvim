local Hooks = {}
Hooks.__index = Hooks

function Hooks.new(raw_hooks)
  vim.validate({ raw_hooks = { raw_hooks, "table" } })
  vim.validate({
    success = { raw_hooks.success, "function" },
    failure = { raw_hooks.failure, "function" },
    pre_execute = { raw_hooks.pre_execute, "function" },
  })
  local tbl = {
    success = raw_hooks.success,
    failure = raw_hooks.failure,
    pre_execute = raw_hooks.pre_execute,
  }
  return setmetatable(tbl, Hooks)
end

function Hooks.info_factory()
  local start_time = vim.loop.now()
  return function()
    return { elapsed_ms = vim.loop.now() - start_time }
  end
end

return Hooks
