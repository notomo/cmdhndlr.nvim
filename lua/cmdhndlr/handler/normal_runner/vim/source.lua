local M = {}

function M.run_file(ctx, path)
  return ctx.job_factory:create({ "nvim", "--headless", "+source " .. path, "+quitall!" })
end

function M.run_string(ctx, str)
  local path = require("cmdhndlr.lib.file").temporary(str)
  return M.run_file(ctx, path)
end

return M
