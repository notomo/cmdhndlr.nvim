local M = {}

function M.run_file(self, path)
  return self.job_factory:create({ "deno", "test", path })
end

return M
