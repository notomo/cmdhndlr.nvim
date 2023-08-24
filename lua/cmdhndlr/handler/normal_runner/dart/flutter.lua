local M = {}

function M.run_file(ctx)
  return ctx.job_factory:create({ "flutter", "run" })
end

M.working_dir_marker = require("cmdhndlr.util.working_dir").upward_marker("pubspec.yaml")

return M
