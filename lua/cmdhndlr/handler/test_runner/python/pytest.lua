local M = {}

function M.run_file(self, path)
  return self.job_factory:create({"pytest", "--capture=no", path})
end

return M
