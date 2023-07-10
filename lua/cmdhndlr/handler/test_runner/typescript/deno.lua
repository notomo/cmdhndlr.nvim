local M = {}

function M.run_file(self, path, filter)
  local cmd = { "deno", "test" }
  if filter then
    table.insert(cmd, "--filter=" .. filter)
  end
  table.insert(cmd, path)

  local extra_args = vim.b.cmdhndlr_test_deno_args
  if extra_args then
    vim.list_extend(cmd, extra_args)
  end

  return self.job_factory:create(cmd)
end

M.working_dir_marker = require("cmdhndlr.util.working_dir").upward_marker("deno.json", "deno.jsonc", "import_map.json")

return M
