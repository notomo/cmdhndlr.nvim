local M = {}

function M.format(ctx, path, stdout_collector)
  local content = require("cmdhndlr.lib.file").read_all(path)
  return ctx.job_factory:create({ "prettier", "--parser", "json", "--stdin-filepath", path }, {
    input = content,
    on_stdout = stdout_collector,
    as_job = true,
  })
end

local prettier = vim.deepcopy(require("cmdhndlr.handler.format_runner.javascript.prettier"))
M.working_dir_marker = prettier.working_dir_marker

return M
