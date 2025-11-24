local M = {}

M.opts = { target = "start" }

function M.run_file(ctx, _)
  return ctx.job_factory:create({ "node", "--run", ctx.opts.target })
end

M.working_dir_marker = require("cmdhndlr.util.working_dir").upward_marker("package.json")

return M
