local M = {}

function M.run_file(self, path)
  return self.job_factory:create({ "unzip", path })
end

return M
