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

    local job, err = require("cmdhndlr.vendor.misclib.job").open_terminal(cmd, opts)
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
