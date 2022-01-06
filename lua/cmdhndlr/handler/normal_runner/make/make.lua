local M = {}

M.opts = { target = "" }

function M.run_file(self, _)
  local cmd = { "make" }

  local file_path = self.working_dir:marker()
  if file_path then
    vim.list_extend(cmd, { "-f", file_path })
  end

  if self.opts.target ~= "" then
    table.insert(cmd, self.opts.target)
  end

  return self.job_factory:create(cmd)
end

M.working_dir_marker = require("cmdhndlr.util").working_dir.upward_marker("Makefile")

return M
