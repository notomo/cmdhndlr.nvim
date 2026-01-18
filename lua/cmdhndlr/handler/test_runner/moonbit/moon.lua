local M = {}

function M.run_file(ctx, path, filter)
  local cmd = { "moon", "test", "-v", path }
  if filter then
    vim.list_extend(cmd, { "--filter", filter })
  end
  return ctx.job_factory:create(cmd)
end

return M
