local M = {}

function M.format(self, path, stdout_collector)
  local content = require("cmdhndlr.lib.file").read_all(path)
  local dir_path = vim.fs.basename(path)
  return self.job_factory:create({ "goimports", "-srcdir", dir_path }, {
    input = content,
    on_stdout = stdout_collector,
    as_job = true,
  })
end

return M
