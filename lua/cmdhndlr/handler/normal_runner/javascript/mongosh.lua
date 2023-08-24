local M = {}

function M.run_file(ctx, path)
  local input, err = require("cmdhndlr.lib.file").read_all(path)
  if err then
    require("cmdhndlr.vendor.misclib.message").error(err)
  end
  input = input .. "\nexit;\n"
  return ctx.job_factory:create({ "mongosh" }, { input = input })
end

return M
