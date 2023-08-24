local M = {}

M.opts = { target = "" }

function M.run_file(ctx, _)
  local cmd = { "make" }

  local file_path = ctx.working_dir:marker()
  if file_path then
    vim.list_extend(cmd, { "-f", file_path })
  end

  if ctx.opts.target ~= "" then
    table.insert(cmd, ctx.opts.target)
  end

  return ctx.job_factory:create(cmd)
end

M.working_dir_marker = require("cmdhndlr.util.working_dir").upward_marker("Makefile")

return M
