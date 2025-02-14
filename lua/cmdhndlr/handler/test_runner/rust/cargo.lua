local M = {}

function M.run_file(ctx, _, filter)
  local cmd = { "cargo", "test", "--all-features" }
  if filter then
    table.insert(cmd, filter)
  end
  return ctx.job_factory:create(cmd)
end

M.working_dir_marker = require("cmdhndlr.util.working_dir").upward_marker("Cargo.toml")

return M
