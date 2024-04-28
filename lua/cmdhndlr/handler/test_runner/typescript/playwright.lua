local M = {}

function M.run_file(ctx, path)
  local cmd = {}
  vim.list_extend(cmd, ctx.opts.cmd)

  local config_path = ctx.working_dir:marker()
  if config_path then
    vim.list_extend(cmd, { "--config", config_path })
  end

  vim.list_extend(cmd, ctx.opts.extra_args)

  table.insert(cmd, path)
  return ctx.job_factory:create(cmd)
end

M.working_dir_marker = require("cmdhndlr.util.working_dir").upward_marker("playwright.config.ts")

M.opts = {
  cmd = { "npx", "playwright", "test" },
  extra_args = {},
}

return M
