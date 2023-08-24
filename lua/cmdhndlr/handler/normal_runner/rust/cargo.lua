local M = {}

function M.run_file(ctx, path)
  return ctx.job_factory:create({ "cargo", "run", path })
end

M.working_dir_marker = require("cmdhndlr.util.working_dir").upward_marker("Cargo.toml")

return M
