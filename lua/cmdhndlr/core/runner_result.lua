local RunnerResult = {}

function RunnerResult.new(bufnr, job)
  vim.validate({ bufnr = { bufnr, "number" }, job = { job, "table" } })
  local tbl = { bufnr = bufnr, _job = job }
  return setmetatable(tbl, RunnerResult)
end

function RunnerResult.__index(self, k)
  return rawget(RunnerResult, k) or self._job[k]
end

function RunnerResult.input(self, text)
  return self._job:input(text)
end

return RunnerResult
