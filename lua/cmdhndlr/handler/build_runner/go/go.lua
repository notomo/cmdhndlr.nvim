local M = {}

function M.build(ctx, _)
  local temp = require("cmdhndlr.lib.file").temporary()
  return ctx.job_factory:create({ "go", "build", "-o", temp })
end

return M
