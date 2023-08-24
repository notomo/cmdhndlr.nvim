local M = {}

function M.run_file(self, path)
  return self.job_factory:create({ "nvim", "--headless", "+source " .. path, "+quitall!" })
end

function M.run_string(self, str)
  local path = require("cmdhndlr.lib.file").temporary(str)
  return M.run_file(self, path)
end

return M
