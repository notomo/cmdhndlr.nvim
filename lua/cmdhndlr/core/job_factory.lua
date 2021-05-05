local M = {}

local Job = {}
Job.__index = Job
M.Job = Job

function Job.new(cmd, opts)
  local id = vim.fn.termopen(cmd, opts)
  -- TODO: error handling
  local tbl = {_id = id}
  return setmetatable(tbl, Job)
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
