local M = {}

function M.run_file(self, _)
  return self.job_factory:create({ "npx", "jest" })
end

M.working_dir = require("cmdhndlr.util").working_dir.upward_pattern("node_modules")

return M
