local JobFactory = {}
JobFactory.__index = JobFactory

function JobFactory.new(observer, cwd, env, log_file_path)
  vim.validate({
    observer = { observer, "table" },
    cwd = { cwd, "string" },
    env = { env, "table" },
    log_file_path = { log_file_path, "string" },
  })
  local tbl = {
    _observer = observer,
    _cwd = cwd,
    _env = vim.tbl_isempty(env) and vim.empty_dict() or env,
    _log_file_path = log_file_path,
  }
  return setmetatable(tbl, JobFactory)
end

local log = function(cmd, log_file_path)
  local log_dir = vim.fn.fnamemodify(log_file_path, ":h")
  vim.fn.mkdir(log_dir, "p")

  local log_file = io.open(log_file_path, "a")
  if not log_file then
    return nil, "could not open log file: " .. log_file_path
  end
  local msg
  if type(cmd) == "table" then
    msg = table.concat(cmd, " ")
  else
    msg = cmd
  end
  log_file:write(("[%s] %s\n"):format(os.date(), msg))
  log_file:close()
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
    log(cmd, self._log_file_path)

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
