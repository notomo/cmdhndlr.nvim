local M = {}

M.cmd = "busted"

function M.run_file(self, path, filter)
  local cmd = { self.cmd }
  if filter then
    filter = filter:gsub("%(", "%%("):gsub("%)", "%%)"):gsub("%-", "%%-")
    vim.list_extend(cmd, { "--filter", filter })
  end
  table.insert(cmd, path)
  return self.job_factory:create(cmd)
end

return M
