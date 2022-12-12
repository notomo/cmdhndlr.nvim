local M = {}

function M.run_file(self, path)
  return self.job_factory:create({ "tar", "-xvf", path })
end

return M
