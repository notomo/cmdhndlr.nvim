local M = {}

function M.build(ctx, path)
  local temp = require("cmdhndlr.lib.file").temporary()
  return ctx.job_factory:create({ "clang", "-o", temp, path })
end

return M
