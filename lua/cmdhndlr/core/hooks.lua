local Hooks = {}
Hooks.__index = Hooks

function Hooks.new(raw_hooks)
  vim.validate({ raw_hooks = { raw_hooks, "table" } })
  vim.validate({
    on_success = { raw_hooks.success, "function" },
    on_failure = { raw_hooks.failure, "function" },
  })
  local tbl = {
    success = raw_hooks.success,
    failure = raw_hooks.failure,
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
