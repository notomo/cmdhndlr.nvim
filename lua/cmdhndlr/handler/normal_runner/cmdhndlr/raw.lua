local M = {}

M.opts = { cmd = {} }

function M.run_file(ctx, _)
  return ctx.job_factory:create(ctx.opts.cmd)
end

return M
