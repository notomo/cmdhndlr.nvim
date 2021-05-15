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

function JobFactory.new(hooks, default_cwd)
  vim.validate({hooks = {hooks, "table"}, default_cwd = {default_cwd, "string"}})
  local tbl = {_default_cwd = default_cwd, _hooks = hooks}
  return setmetatable(tbl, JobFactory)
end

function JobFactory.create(self, cmd, opts)
  vim.validate({cmd = {cmd, "table"}, opts = {opts, "table", true}})
  opts = opts or {stderr_buffered = false}
  opts.cwd = opts.cwd or self._default_cwd

  local on_exit = opts.on_exit or function()
  end
  opts.on_exit = function(job_id, exit_code)
    on_exit(job_id, exit_code)
    if exit_code == 0 then
      self._hooks.success()
    else
      self._hooks.failure()
    end
  end

  return Job.new(cmd, opts)
end

return M
