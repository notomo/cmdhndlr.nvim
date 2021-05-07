local M = {}

M.opts = {
  f = function()
    return "not implemented"
  end,
}

function M.run_file(self, path)
  return self.opts.f(self, path)
end

function M.run_string(self, str)
  return self.opts.f(self, str)
end

return M
