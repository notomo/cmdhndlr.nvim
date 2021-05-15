local M = {}

local RunnerRawOutput = {}
RunnerRawOutput.__index = RunnerRawOutput

function RunnerRawOutput.new(hooks, output, is_error)
  vim.validate({
    hooks = {hooks, "table"},
    output = {output, "string"},
    is_error = {is_error, "boolean", true},
  })
  local tbl = {_hooks = hooks, output = output, is_error = is_error or false}
  return setmetatable(tbl, RunnerRawOutput)
end

function RunnerRawOutput.hook(self)
  if self.is_error then
    return self._hooks.failure()
  end
  return self._hooks.success()
end

local RunnerJobOutput = {}

function RunnerJobOutput.new(job)
  vim.validate({job = {job, "table"}})
  local tbl = {output = nil, _job = job}
  return setmetatable(tbl, RunnerJobOutput)
end

function RunnerJobOutput.__index(self, k)
  return rawget(RunnerJobOutput, k) or self._job[k]
end

function RunnerJobOutput.hook()
  -- nop
end

local RunnerResult = {}
M.RunnerResult = RunnerResult

function RunnerResult.ok(hooks, output)
  if type(output) == "string" then
    return RunnerRawOutput.new(hooks, output)
  end
  return RunnerJobOutput.new(output)
end

function RunnerResult.error(hooks, err)
  return RunnerRawOutput.new(hooks, err, true)
end

return M
