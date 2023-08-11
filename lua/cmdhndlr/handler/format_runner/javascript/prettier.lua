local M = {}

function M.format(self, path, stdout_collector)
  local content = self.filelib.read_all(path)
  return self.job_factory:create({ "prettier", "--stdin-filepath", path }, {
    input = content,
    on_stdout = stdout_collector,
    as_job = true,
  })
end

return M
