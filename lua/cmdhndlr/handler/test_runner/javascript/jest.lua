local M = {}

function M.run_file(ctx, path, filter, is_leaf)
  local cmd = { "npx", "jest" }
  if filter then
    local suffix = is_leaf and "$" or ""
    table.insert(cmd, "--testNamePattern=" .. filter .. suffix)
  end
  table.insert(cmd, path)
  return ctx.job_factory:create(cmd)
end

M.working_dir = require("cmdhndlr.util.working_dir").upward_pattern("node_modules")

return M
