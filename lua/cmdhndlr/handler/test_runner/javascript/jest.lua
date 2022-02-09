local M = {}

function M.run_file(self, path, filter)
  local cmd = { "npx", "jest" }
  if filter then
    table.insert(cmd, "--testNamePattern=" .. filter)
  end
  table.insert(cmd, path)
  return self.job_factory:create(cmd)
end

M.working_dir = require("cmdhndlr.util").working_dir.upward_pattern("node_modules")

return M
