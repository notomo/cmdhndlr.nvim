local M = {}

M.opts = {
  f = function()
    return "not implemented"
  end,
}

function M.run_file(self, path)
  return self.opts.f(self, path)
end

return M
