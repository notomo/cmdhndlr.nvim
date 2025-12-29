local M = {}

function M.run_file(ctx, path)
  local cmd = { "moon", "test", "-v", path }
  return ctx.job_factory:create(cmd)
end

return M
