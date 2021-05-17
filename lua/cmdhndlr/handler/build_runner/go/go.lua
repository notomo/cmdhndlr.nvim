local M = {}

function M.build(self, _)
  local temp = self.filelib.temporary("")
  return self.job_factory:create({"go", "build", "-o", temp})
end

return M
