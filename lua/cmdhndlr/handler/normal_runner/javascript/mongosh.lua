local M = {}

function M.run_file(ctx, path)
  local input, err = require("cmdhndlr.lib.file").read_all(path)
  if err then
    error("[cmdhndlr] " .. err, 0)
  end
  input = input .. "\nexit;\n"
  return ctx.job_factory:create({ "mongosh" }, { input = input })
end

return M
