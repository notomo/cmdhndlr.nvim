local M = {}

local RunnerRawOutput = {}
RunnerRawOutput.__index = RunnerRawOutput

function RunnerRawOutput.new(hook, output)
  vim.validate({hook = {hook, "function"}, output = {output, "string"}})
  local tbl = {_hook = hook, output = output, is_error = false}
  return setmetatable(tbl, RunnerRawOutput)
end

function RunnerRawOutput.hook(self)
  return self._hook()
end

local RunnerRawError = {}
RunnerRawError.__index = RunnerRawError

function RunnerRawError.new(hook, err)
  vim.validate({hook = {hook, "function"}, err = {err, "string"}})
  local tbl = {_hook = hook, output = err, is_error = true}
  return setmetatable(tbl, RunnerRawError)
end

function RunnerRawError.hook(self)
  return self._hook()
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
    return RunnerRawOutput.new(hooks.success, output)
  end
  return RunnerJobOutput.new(output)
end

function RunnerResult.error(hooks, err)
  return RunnerRawError.new(hooks.failure, err)
end

return M
