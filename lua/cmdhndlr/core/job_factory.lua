local Job = {}
Job.__index = Job

function Job.new(cmd, opts, output_bufnr)
  local ok, result
  vim.api.nvim_buf_call(output_bufnr, function()
    ok, result = pcall(vim.fn.termopen, cmd, opts)
  end)
  if not ok then
    return nil, result
  end

  local tbl = {
    _id = result,
    bufnr = output_bufnr,
  }
  return setmetatable(tbl, Job), nil
end

function Job.is_running(self)
  return vim.fn.jobwait({ self._id }, 0)[1] == -1
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

function Job.close_stdin(self)
  vim.fn.chanclose(self._id, "stdin")
end

local JobFactory = {}
JobFactory.__index = JobFactory

function JobFactory.new(observer, cwd, env)
  vim.validate({
    observer = { observer, "table" },
    cwd = { cwd, "string" },
    env = { env, "table" },
  })
  local tbl = {
    _observer = observer,
    _cwd = cwd,
    _env = vim.tbl_isempty(env) and vim.empty_dict() or env,
  }
  return setmetatable(tbl, JobFactory)
end

function JobFactory.create(self, cmd, special_opts)
  special_opts = special_opts or {}
  return require("cmdhndlr.vendor.promise").new(function(resolve, reject)
    local opts = {
      cwd = self._cwd,
      env = self._env,
      on_exit = function(_, exit_code)
        resolve(exit_code == 0)
      end,
    }

    self._observer.pre_start(cmd)

    local output_bufnr = vim.api.nvim_create_buf(false, true)
    local job, err = Job.new(cmd, opts, output_bufnr)
    if err then
      return reject(err)
    end

    self._observer.post_start(job)

    if special_opts.input then
      job:input(special_opts.input)
      job:close_stdin()
    end
  end)
end

return JobFactory
