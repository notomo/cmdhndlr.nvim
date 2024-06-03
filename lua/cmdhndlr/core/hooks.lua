local Hooks = {}
Hooks.__index = Hooks

function Hooks.new(raw_hooks)
  vim.validate({ raw_hooks = { raw_hooks, "table" } })
  vim.validate({
    success = { raw_hooks.success, "function" },
    failure = { raw_hooks.failure, "function" },
    pre_execute = { raw_hooks.pre_execute, "function" },
    post_execute = { raw_hooks.post_execute, "function" },
  })
  local tbl = {
    success = raw_hooks.success,
    failure = raw_hooks.failure,
    pre_execute = raw_hooks.pre_execute,
    post_execute = raw_hooks.post_execute,
  }
  return setmetatable(tbl, Hooks)
end

function Hooks.info_factory()
  local start_time = vim.uv.now()
  return function(window_id)
    return {
      elapsed_ms = vim.uv.now() - start_time,
      window_id = window_id,
    }
  end
end

return Hooks
