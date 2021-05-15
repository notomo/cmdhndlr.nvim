local M = {}

local RunnerOutput = {}

function RunnerOutput.new(output, job, is_error)
  vim.validate({
    output = {output, "string", true},
    job = {job, "table", true},
    is_error = {is_error, "boolean", true},
  })
  local tbl = {output = output, _job = job or {}, is_error = is_error or false}
  return setmetatable(tbl, RunnerOutput)
end

function RunnerOutput.__index(self, k)
  return rawget(RunnerOutput, k) or self._job[k]
end

local RunnerResult = {}
M.RunnerResult = RunnerResult

function RunnerResult.ok(output)
  if type(output) == "string" then
    return RunnerOutput.new(output, nil)
  end
  return RunnerOutput.new(nil, output)
end

function RunnerResult.error(err)
  vim.validate({err = {err, "string"}})
  return RunnerOutput.new(err, nil, true)
end

return M
