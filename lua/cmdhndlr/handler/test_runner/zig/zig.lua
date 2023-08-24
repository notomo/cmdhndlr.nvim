local M = {}

function M.run_file(ctx, path)
  return ctx.job_factory:create({ "zig", "test", path })
end

return M
