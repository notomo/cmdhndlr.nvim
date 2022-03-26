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

  local tbl = {
    _id = result,
    bufnr = output_bufnr,
  }
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

function JobFactory.new(hooks, cwd, env)
  vim.validate({
    hooks = { hooks, "table" },
    cwd = { cwd, "string" },
    env = { env, "table" },
  })
  local tbl = {
    _cwd = cwd,
    _hooks = hooks,
    _env = vim.tbl_isempty(env) and vim.empty_dict() or env,
  }
  return setmetatable(tbl, JobFactory)
end

function JobFactory.create(self, cmd)
  local info_factory = self._hooks:info_factory()
  local opts = {
    cwd = self._cwd,
    env = self._env,
    on_exit = function(_, exit_code)
      if exit_code == 0 then
        self._hooks.success(info_factory())
      else
        self._hooks.failure(info_factory())
      end
    end,
  }

  self._hooks.pre_execute(cmd)

  local output_bufnr = vim.api.nvim_create_buf(false, true)
  return Job.new(cmd, opts, output_bufnr)
end

return M
