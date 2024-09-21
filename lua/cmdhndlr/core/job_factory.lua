local JobFactory = {}
JobFactory.__index = JobFactory

function JobFactory.new(observer, cwd, env, log_file_path, build_cmd, build_cmd_ctx)
  vim.validate({
    observer = { observer, "table" },
    cwd = { cwd, "string" },
    env = { env, "table" },
    log_file_path = { log_file_path, "string" },
    build_cmd = { build_cmd, "function", true },
    build_cmd_ctx = { build_cmd_ctx, "table" },
  })
  local tbl = {
    _observer = observer,
    _cwd = cwd,
    _env = vim.tbl_isempty(env) and vim.empty_dict() or env,
    _log_file_path = log_file_path,
    _build_cmd = build_cmd,
    _build_cmd_ctx = build_cmd_ctx,
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
  local promise, resolve, reject = require("cmdhndlr.vendor.promise").with_resolvers()

  local opts = {
    cwd = self._cwd,
    env = self._env,
    on_exit = function(_, exit_code)
      resolve(exit_code == 0)
    end,
    on_stdout = special_opts.on_stdout,
  }

  self._build_cmd(cmd, function(built_cmd)
    if not built_cmd then
      return reject("canceled")
    end

    local reusable = self._observer.pre_start(built_cmd)
    if reusable then
      return resolve(true, true)
    end

    log(built_cmd, self._log_file_path)

    local job
    if special_opts.as_job then
      job = require("cmdhndlr.vendor.misclib.job").start(built_cmd, opts)
    else
      job = require("cmdhndlr.vendor.misclib.job").open_terminal(built_cmd, opts)
    end
    if type(job) == "string" then
      local err = job
      return reject(err)
    end

    self._observer.post_start(job)

    if special_opts.input then
      job:input(special_opts.input)
      job:close_stdin()
    end
  end, self._build_cmd_ctx)

  return promise
end

return JobFactory
