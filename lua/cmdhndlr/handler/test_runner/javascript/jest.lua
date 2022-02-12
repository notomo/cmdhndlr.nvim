local M = {}

function M.run_file(self, path, filter, is_leaf)
  local cmd = { "npx", "jest" }
  if filter then
    local suffix = is_leaf and "$" or ""
    table.insert(cmd, "--testNamePattern=" .. filter .. suffix)
  end
  table.insert(cmd, path)
  return self.job_factory:create(cmd)
end

M.working_dir = require("cmdhndlr.util").working_dir.upward_pattern("node_modules")

return M
