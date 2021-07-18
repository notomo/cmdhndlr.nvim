local M = {}

local RunnerOutput = {}
RunnerOutput.__index = RunnerOutput

function RunnerOutput.new(info, bufnr, hook)
  vim.validate({info = {info, "table"}, bufnr = {bufnr, "number"}, hook = {hook, "function", true}})
  local tbl = {
    bufnr = bufnr,
    _info = info,
    _hook = hook or function()
    end,
  }
  return setmetatable(tbl, RunnerOutput)
end

function RunnerOutput.return_output(self)
  self._hook(self._info)
  return self, nil
end

function RunnerOutput.input(_)
  return "can't input"
end

local RunnerRawOutput = {}
RunnerRawOutput.__index = RunnerRawOutput

function RunnerRawOutput.new(output, raw_output)
  vim.validate({output = {output, "table"}, raw_output = {raw_output, "string"}})
  local tbl = {output = raw_output, is_error = false, _output = output}
  return setmetatable(tbl, RunnerRawOutput)
end

function RunnerRawOutput.__index(self, k)
  return rawget(RunnerRawOutput, k) or self._output[k]
end

function RunnerRawOutput.is_running(_)
  return false
end

local RunnerRawError = {}

function RunnerRawError.new(output, err)
  vim.validate({output = {output, "table"}, err = {err, "string"}})
  local tbl = {output = err, is_error = true, _output = output}
  return setmetatable(tbl, RunnerRawError)
end

function RunnerRawError.__index(self, k)
  return rawget(RunnerRawError, k) or self._output[k]
end

function RunnerRawError.is_running(_)
  return false
end

local RunnerJobOutput = {}

function RunnerJobOutput.new(output, job)
  vim.validate({output = {output, "table"}, job = {job, "table"}})
  local tbl = {output = nil, _job = job, _output = output}
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

function RunnerResult.ok(output_bufnr, hooks, info, raw_output)
  if type(raw_output) == "string" then
    local output = RunnerOutput.new(info, output_bufnr, hooks.success)
    return RunnerRawOutput.new(output, raw_output)
  end
  local output = RunnerOutput.new(info, output_bufnr)
  return RunnerJobOutput.new(output, raw_output)
end

function RunnerResult.error(output_bufnr, hooks, info, err)
  local output = RunnerOutput.new(info, output_bufnr, hooks.failure)
  return RunnerRawError.new(output, err)
end

return M
