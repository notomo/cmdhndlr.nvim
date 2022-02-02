local M = {}

function M.run_file(self, _, filter)
  local cmd = { "go", "test", "-v" }
  if filter then
    table.insert(cmd, "--run=" .. ("^%s$"):format(filter))
  end
  return self.job_factory:create(cmd)
end

return M
