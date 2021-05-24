local M = {}

local RunnerOutput = {}
RunnerOutput.__index = RunnerOutput

function RunnerOutput.new(hook)
  vim.validate({hook = {hook, "function", true}})
  local tbl = {
    _hook = hook or function()
    end,
  }
  return setmetatable(tbl, RunnerOutput)
end

function RunnerOutput.return_output(self)
  self._hook()
  return self, nil
end

local RunnerRawOutput = {}
RunnerRawOutput.__index = RunnerRawOutput

function RunnerRawOutput.new(hook, output)
  vim.validate({output = {output, "string"}})
  local tbl = {output = output, is_error = false, _output = RunnerOutput.new(hook)}
  return setmetatable(tbl, RunnerRawOutput)
end

function RunnerRawOutput.__index(self, k)
  return rawget(RunnerRawOutput, k) or self._output[k]
end

local RunnerRawError = {}

function RunnerRawError.new(hook, err)
  vim.validate({err = {err, "string"}})
  local tbl = {output = err, is_error = true, _output = RunnerOutput.new(hook)}
  return setmetatable(tbl, RunnerRawError)
end

function RunnerRawError.__index(self, k)
  return rawget(RunnerRawError, k) or self._output[k]
end

local RunnerJobOutput = {}

function RunnerJobOutput.new(job)
  vim.validate({job = {job, "table"}})
  local tbl = {output = nil, _job = job, _output = RunnerOutput.new()}
  return setmetatable(tbl, RunnerJobOutput)
end

function RunnerJobOutput.__index(self, k)
  return rawget(RunnerJobOutput, k) or self._output[k] or self._job[k]
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
