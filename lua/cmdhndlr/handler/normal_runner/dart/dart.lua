local M = {}

function M.run_file(self, path)
  return self.job_factory:create({ "dart", "run", path })
end

return M
