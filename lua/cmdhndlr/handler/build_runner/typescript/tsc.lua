local M = {}

function M.build(ctx, path)
  return ctx.job_factory:create({ "npx", "tsc", "--noEmit", path })
end

M.working_dir_marker = require("cmdhndlr.util.working_dir").upward_marker("tsconfig.json")

return M
