local M = {}

function M.run_file(ctx, path)
  return ctx.job_factory:create({ "tar", "-xvf", path })
end

return M
