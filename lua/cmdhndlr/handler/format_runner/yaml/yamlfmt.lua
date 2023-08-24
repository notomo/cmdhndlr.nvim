local M = {}

function M.format(ctx, path, stdout_collector)
  local content = require("cmdhndlr.lib.file").read_all(path)
  return ctx.job_factory:create({ "yamlfmt", "-" }, {
    input = content,
    on_stdout = stdout_collector,
    as_job = true,
  })
end

return M
