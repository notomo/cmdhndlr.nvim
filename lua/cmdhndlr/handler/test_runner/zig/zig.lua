local M = {}

function M.run_file(self, path)
  return self.job_factory:create({ "zig", "test", path })
end

return M
