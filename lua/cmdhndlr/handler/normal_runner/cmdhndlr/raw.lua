local M = {}

M.opts = { cmd = {} }

function M.run_file(self, _)
  return self.job_factory:create(self.opts.cmd)
end

return M
