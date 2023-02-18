local M = {}

function M.run_file(self, _, filter, is_leaf)
  local cmd = { "go", "test", "-v" }
  if filter then
    local suffix = is_leaf and "$" or ""
    table.insert(cmd, "--run=" .. ("^%s%s"):format(filter, suffix))
  end
  return self.job_factory:create(cmd)
end

return M
