local M = {}

local RunnerOutput = {}
RunnerOutput.__index = RunnerOutput

function RunnerOutput.new(bufnr, hook)
  vim.validate({bufnr = {bufnr, "number"}, hook = {hook, "function", true}})
  local tbl = {
    bufnr = bufnr,
    _hook = hook or function()
    end,
  }
  return setmetatable(tbl, RunnerOutput)
end

function RunnerOutput.return_output(self)
  self._hook()
  return self, nil
end

function RunnerOutput.input(_)
  return "can't input"
end

local RunnerRawOutput = {}
RunnerRawOutput.__index = RunnerRawOutput

function RunnerRawOutput.new(bufnr, hook, output)
  vim.validate({output = {output, "string"}})
  local tbl = {output = output, is_error = false, _output = RunnerOutput.new(bufnr, hook)}
  return setmetatable(tbl, RunnerRawOutput)
end

function RunnerRawOutput.__index(self, k)
  return rawget(RunnerRawOutput, k) or self._output[k]
end

local RunnerRawError = {}

function RunnerRawError.new(bufnr, hook, err)
  vim.validate({err = {err, "string"}})
  local tbl = {output = err, is_error = true, _output = RunnerOutput.new(bufnr, hook)}
  return setmetatable(tbl, RunnerRawError)
end

function RunnerRawError.__index(self, k)
  return rawget(RunnerRawError, k) or self._output[k]
end

local RunnerJobOutput = {}

function RunnerJobOutput.new(bufnr, job)
  vim.validate({job = {job, "table"}})
  local tbl = {output = nil, _job = job, _output = RunnerOutput.new(bufnr)}
  return setmetatable(tbl, RunnerJobOutput)
end

function RunnerJobOutput.__index(self, k)
  return rawget(RunnerJobOutput, k) or self._output[k] or self._job[k]
end

function RunnerJobOutput.input(self, text)
  return self._job:input(text)
end

local RunnerResult = {}
M.RunnerResult = RunnerResult

function RunnerResult.ok(output_bufnr, hooks, output)
  if type(output) == "string" then
    return RunnerRawOutput.new(output_bufnr, hooks.success, output)
  end
  return RunnerJobOutput.new(output_bufnr, output)
end

function RunnerResult.error(output_bufnr, hooks, err)
  return RunnerRawError.new(output_bufnr, hooks.failure, err)
end

return M
