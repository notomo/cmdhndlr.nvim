local M = {}

function M.format(ctx, path)
  return ctx.job_factory
    :create({ "moon", "fmt", path }, {
      as_job = true,
    })
    :next(function(result_ctx)
      result_ctx.reload = true
      return result_ctx
    end)
end

return M
