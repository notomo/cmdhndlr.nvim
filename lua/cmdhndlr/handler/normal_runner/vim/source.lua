local M = {}

function M.run_file(self, path)
  return self.job_factory:create({ "nvim", "--headless", "+source " .. path, "+quitall!" })
end

function M.run_string(self, str)
  local path = self.filelib.temporary(str)
  return self:run_file(path)
end

return M
