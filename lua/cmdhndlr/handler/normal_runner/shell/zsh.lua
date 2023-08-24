local M = {}

function M.run_file(ctx, path)
  return ctx.job_factory:create({ "zsh", path })
end

function M.run_string(ctx, str)
  local path = require("cmdhndlr.lib.file").temporary(str)
  return M.run_file(ctx, path)
end

return M
