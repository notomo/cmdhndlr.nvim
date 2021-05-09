local M = {}

M.opts = {target = ""}

function M.run_file(self, _)
  local cmd = {"make"}
  if self.opts.target ~= "" then
    table.insert(cmd, self.opts.target)
  end
  return self.job_factory:create(cmd)
end

M.working_dir = require("cmdhndlr.util").working_dir.upward_pattern("Makefile", "*.mk")

return M
