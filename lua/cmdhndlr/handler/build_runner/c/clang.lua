local M = {}

function M.build(self, path)
  local temp = require("cmdhndlr.lib.file").temporary()
  return self.job_factory:create({ "clang", "-o", temp, path })
end

return M
