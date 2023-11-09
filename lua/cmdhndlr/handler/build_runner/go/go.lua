local M = {}

function M.build(ctx, path)
  local temp = require("cmdhndlr.lib.file").temporary()
  if vim.endswith(path, "_test.go") then
    return ctx.job_factory:create({ "go", "test", "-c", "-o", temp })
  end
  return ctx.job_factory:create({ "go", "build", "-o", temp })
end

return M
