local M = {}

function M.build(self, _)
  local temp = require("cmdhndlr.lib.file").temporary()
  return self.job_factory:create({ "go", "build", "-o", temp })
end

return M
