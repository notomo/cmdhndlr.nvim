local M = {}

M.opts = {target = "start"}

function M.run_file(self, _)
  return self.job_factory:create({"npm", "run", self.opts.target})
end

M.working_dir_marker = require("cmdhndlr.util").working_dir.upward_marker("package.json")

return M
