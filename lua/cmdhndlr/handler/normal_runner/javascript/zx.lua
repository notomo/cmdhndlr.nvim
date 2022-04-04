local M = {}

function M.run_file(self, path)
  return self.job_factory:create({ "zx", path })
end

return M
