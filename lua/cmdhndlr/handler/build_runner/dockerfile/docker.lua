local M = {}

function M.build(self, path)
  return self.job_factory:create({ "docker", "build", "-t", "cmdhndlr_temporary", "-f", path, "." })
end

return M
