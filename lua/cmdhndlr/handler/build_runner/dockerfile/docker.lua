local M = {}

function M.build(ctx, path)
  return ctx.job_factory:create({ "docker", "build", "-t", "cmdhndlr_temporary", "-f", path, "." })
end

return M
