local M = {}

function M.run_file(ctx, path)
  return ctx.job_factory:create({ "zx", path })
end

return M
