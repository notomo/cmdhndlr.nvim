local M = {}

local Job = {}
Job.__index = Job
M.Job = Job

function Job.new(cmd, opts, output_bufnr)
  local ok, result
  vim.api.nvim_buf_call(output_bufnr, function()
    ok, result = pcall(vim.fn.termopen, cmd, opts)
  end)
  if not ok then
    return nil, result
  end
  vim.schedule(function()
    vim.cmd("startinsert!")
  end)

  local tbl = { _id = result }
  return setmetatable(tbl, Job), nil
end

function Job.is_running(self)
  return vim.fn.jobwait({ self._id }, 0)[1] == -1
end

function Job.wait(self, ms)
  return vim.wait(ms, function()
    return not self:is_running()
  end, 10)
end

function Job.input(self, text)
  if not self:is_running() then
    return "job is not running"
  end

  local ok, err = pcall(vim.fn.chansend, self._id, text)
  if not ok then
    return err
  end

  return nil
end

local JobFactory = {}
JobFactory.__index = JobFactory
M.JobFactory = JobFactory

function JobFactory.new(output_bufnr, hooks, default_cwd, env)
  vim.validate({
    output_bufnr = { output_bufnr, "number" },
    hooks = { hooks, "table" },
    default_cwd = { default_cwd, "string" },
    env = { env, "table", true },
  })
  local tbl = {
    _output_bufnr = output_bufnr,
    _default_cwd = default_cwd,
    _hooks = hooks,
    _env = env or vim.empty_dict(),
  }
  return setmetatable(tbl, JobFactory)
end

function JobFactory.create(self, cmd, opts)
  vim.validate({ opts = { opts, "table", true } })
  opts = opts or vim.empty_dict()
  opts.cwd = opts.cwd or self._default_cwd
  opts.env = vim.tbl_extend("force", self._env, opts.env or {})

  local on_exit = opts.on_exit or function() end
  local info_factory = self._hooks:info_factory()
  opts.on_exit = function(job_id, exit_code)
    on_exit(job_id, exit_code)
    if exit_code == 0 then
      self._hooks.success(info_factory())
    else
      self._hooks.failure(info_factory())
    end
  end

  return Job.new(cmd, opts, self._output_bufnr)
end

return M
