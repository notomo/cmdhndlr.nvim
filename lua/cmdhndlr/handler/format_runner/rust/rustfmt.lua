local M = {}

function M.format(self, path, stdout_collector)
  local content = require("cmdhndlr.lib.file").read_all(path)
  return self.job_factory:create({ "rustfmt", "--emit=stdout" }, {
    input = content,
    on_stdout = stdout_collector,
    as_job = true,
  })
end

return M
