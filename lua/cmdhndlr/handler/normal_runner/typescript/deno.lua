local M = {}

function M.run_file(self, path)
  return self.job_factory:create({ "deno", "run", path })
end

function M.run_string(self, str)
  local path = require("cmdhndlr.lib.file").temporary(str)
  return self:run_file(path)
end

return M
