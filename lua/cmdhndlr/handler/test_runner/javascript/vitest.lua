local M = {}

M.opts = {
  cmd = { "npx", "vitest", "run" },
  extra_args = {},
}

function M.run_file(ctx, path, filter, is_leaf)
  local cmd = {}

  vim.list_extend(cmd, ctx.opts.cmd)

  if filter then
    local suffix = is_leaf and "$" or ""
    table.insert(cmd, "--testNamePattern=" .. vim.fn.escape(filter, [=[^$.*+?[](){}|]=]) .. suffix)
  end

  vim.list_extend(cmd, ctx.opts.extra_args)

  table.insert(cmd, path)
  return ctx.job_factory:create(cmd)
end

M.working_dir_marker = require("cmdhndlr.util.working_dir").upward_marker("vitest.config.ts")

return M
