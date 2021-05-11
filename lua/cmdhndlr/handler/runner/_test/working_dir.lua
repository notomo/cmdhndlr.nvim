local M = {}

function M.run_file()
end

function M.run_string(self)
  return self.working_dir:get()
end

M.working_dir = require("cmdhndlr.util").working_dir.upward_pattern("dir1", "dir2")

return M
