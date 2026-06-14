local M = {}

function M.run_file(ctx, path, filter, is_leaf)
  local cmd = { "ntf" }
  if filter then
    filter = filter:gsub("%(", "%%("):gsub("%)", "%%)"):gsub("%-", "%%-")
    local suffix = is_leaf and "$" or ""
    vim.list_extend(cmd, { "--filter", filter .. suffix })
  end
  table.insert(cmd, path)
  return ctx.job_factory:create(cmd)
end

M.working_dir = require("cmdhndlr.util.working_dir").upward_pattern(".git")

return M
