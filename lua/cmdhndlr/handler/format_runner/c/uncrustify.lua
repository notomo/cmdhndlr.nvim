local M = {}

function M.format(self, path, stdout_collector)
  local content = self.filelib.read_all(path)
  local config_path = self.working_dir:marker()
  return self.job_factory:create({ "uncrustify", "-q", "-l C", "-c", config_path, "--no-backup" }, {
    input = content,
    on_stdout = stdout_collector,
    as_job = true,
  })
end

M.working_dir_marker = require("cmdhndlr.util.working_dir").upward_marker("uncrustify.cfg")

return M
