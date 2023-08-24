local M = {}

function M.run_file(ctx, path)
  return ctx.job_factory:create({ "go", "run", path })
end

return M
