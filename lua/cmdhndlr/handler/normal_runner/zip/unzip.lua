local M = {}

function M.run_file(ctx, path)
  return ctx.job_factory:create({ "unzip", path })
end

return M
