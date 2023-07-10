local M = {}

function M.run_file(self, path)
  return self.job_factory:create({ "cargo", "run", path })
end

M.working_dir_marker = require("cmdhndlr.util.working_dir").upward_marker("Cargo.toml")

return M
