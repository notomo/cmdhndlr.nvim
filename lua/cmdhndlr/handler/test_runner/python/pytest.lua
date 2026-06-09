local M = {}

function M.run_file(ctx, path)
  return ctx.job_factory:create({ "uv", "run", "pytest", "--capture=no", path })
end

return M
