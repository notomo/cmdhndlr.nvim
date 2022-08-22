local M = {}

function M.run_file(self, path)
  local f = io.open(path, "r")
  local text = f:read("*a")
  f:close()
  return self.job_factory:create({ "sqlite3", "-header", "-column" }, { input = text .. ";\n.quit\n" })
end

return M
