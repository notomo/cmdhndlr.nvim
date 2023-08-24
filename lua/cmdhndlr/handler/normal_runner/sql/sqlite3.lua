local M = {}

function M.run_file(ctx, path)
  local f = io.open(path, "r")
  local text = f:read("*a")
  f:close()
  return ctx.job_factory:create({ "sqlite3", "-header", "-column" }, { input = text .. ";\n.quit\n" })
end

return M
