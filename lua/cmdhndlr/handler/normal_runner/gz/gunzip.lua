local M = {}

function M.run_file(ctx, path)
  return ctx.job_factory:create({ "gunzip", "-k", path })
end

return M
