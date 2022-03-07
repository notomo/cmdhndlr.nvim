local M = {}

function M.build(self, path)
  local temp = self.filelib.temporary()
  return self.job_factory:create({ "clang", "-o", temp, path })
end

return M
