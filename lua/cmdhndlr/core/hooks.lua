local Hooks = {}
Hooks.__index = Hooks

--- @param raw_hooks {success:function,failure:function,pre_execute:function,post_execute:function}
function Hooks.new(raw_hooks)
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
  return function(window_id, cmd)
    return {
      elapsed_ms = vim.uv.now() - start_time,
      window_id = window_id,
      cmd = cmd,
    }
  end
end

return Hooks
