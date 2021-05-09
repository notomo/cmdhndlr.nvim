local M = {}

function M.run_file(self, _)
  return self.job_factory:create({"go", "test", "-v"})
end

return M
