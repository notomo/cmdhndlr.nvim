local M = {}

function M.format(ctx, path)
  local result_ctx = ctx.job_factory:create({ "moon", "fmt", path }, {
    as_job = true,
  })
  result_ctx.reload = true
  return result_ctx
end

return M
