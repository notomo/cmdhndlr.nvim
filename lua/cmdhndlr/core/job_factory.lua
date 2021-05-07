local M = {}

local Job = {}
Job.__index = Job
M.Job = Job

function Job.new(cmd, opts)
  local ok, result = pcall(vim.fn.termopen, cmd, opts)
  if not ok then
    return nil, result
  end
  local tbl = {_id = result}
  return setmetatable(tbl, Job), nil
end

function Job.is_running(self)
  return vim.fn.jobwait({self._id}, 0)[1] == -1
end

function Job.wait(self, ms)
  return vim.wait(ms, function()
    return not self:is_running()
  end, 10)
end

local JobFactory = {}
JobFactory.__index = JobFactory
M.JobFactory = JobFactory

function JobFactory.new()
  local tbl = {}
  return setmetatable(tbl, JobFactory)
end

function JobFactory.create(_, cmd, opts)
  vim.validate({cmd = {cmd, "table"}, opts = {opts, "table", true}})
  opts = opts or {stderr_buffered = false}
  return Job.new(cmd, opts)
end

return M
