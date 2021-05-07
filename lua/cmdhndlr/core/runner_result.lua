local M = {}

local RunnerResult = {}
M.RunnerResult = RunnerResult

function RunnerResult.new(runner_output)
  local output
  local job = {}
  if type(runner_output) == "string" then
    output = runner_output
  else
    job = runner_output
  end
  local tbl = {output = output, _job = job}
  return setmetatable(tbl, RunnerResult)
end

function RunnerResult.__index(self, k)
  return rawget(RunnerResult, k) or self._job[k]
end

return M
