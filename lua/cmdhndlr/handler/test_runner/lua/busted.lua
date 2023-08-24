local M = {}

M.opts = { cmd = "busted" }

function M.run_file(ctx, path, filter, is_leaf)
  local cmd = { ctx.opts.cmd }
  if filter then
    filter = filter:gsub("%(", "%%("):gsub("%)", "%%)"):gsub("%-", "%%-")
    local suffix = is_leaf and "$" or ""
    vim.list_extend(cmd, { "--filter", filter .. suffix })
  end
  table.insert(cmd, path)
  return ctx.job_factory:create(cmd)
end

return M
