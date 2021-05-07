local M = {}

function M.run_file(self, path)
  return self.job_factory:create({"bash", path})
end

function M.run_string(self, str)
  local path = self.filelib.temporary(str)
  return self.job_factory:create({"bash", path})
end

return M
