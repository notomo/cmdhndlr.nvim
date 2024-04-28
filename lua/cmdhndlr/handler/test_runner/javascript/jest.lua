local M = {}

M.opts = {
  cmd = { "npx", "jest" },
  extra_args = {},
}

function M.run_file(ctx, path, filter, is_leaf)
  local cmd = {}

  vim.list_extend(cmd, ctx.opts.cmd)

  if filter then
    local suffix = is_leaf and "$" or ""
    table.insert(cmd, "--testNamePattern=" .. filter .. suffix)
  end

  vim.list_extend(cmd, ctx.opts.extra_args)

  table.insert(cmd, vim.fn.escape(path, "[]()$"))
  return ctx.job_factory:create(cmd)
end

M.working_dir = require("cmdhndlr.util.working_dir").upward_pattern("node_modules")

return M
