local M = {}

function M.build(ctx, path)
  return ctx.job_factory:create({ "moon", "build", path })
end

return M
