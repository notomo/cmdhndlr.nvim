local M = {}

function M.run_file(ctx, path)
  local cmd = {}
  vim.list_extend(cmd, ctx.opts.cmd)
  table.insert(cmd, path)

  local config_path = ctx.working_dir:marker()
  if config_path then
    vim.list_extend(cmd, { "--config", config_path })
  end

  local extra_args = ctx.opts.extra_args
  if extra_args then
    vim.list_extend(cmd, extra_args)
  end

  return ctx.job_factory:create(cmd)
end

M.working_dir_marker = require("cmdhndlr.util.working_dir").upward_marker("playwright.config.ts")

M.opts = {
  cmd = { "npx", "playwright", "test" },
  extra_args = {},
}

return M
