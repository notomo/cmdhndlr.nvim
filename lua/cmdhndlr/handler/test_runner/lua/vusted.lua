local M = {}

function M.run_file(self, path)
  return self.job_factory:create({"vusted", path})
end

M.working_dir = require("cmdhndlr.util").working_dir.upward_pattern(".git")

return M
