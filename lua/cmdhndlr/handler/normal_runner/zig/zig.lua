local M = {}

function M.run_file(ctx, path)
  return ctx.job_factory:create({ "zig", "run", path })
end

return M
