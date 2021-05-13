local M = {}

function M.run_file(self, _)
  return self.job_factory:create({"cargo", "test"})
end

M.working_dir_marker = require("cmdhndlr.util").working_dir.upward_marker("Cargo.toml")

return M
