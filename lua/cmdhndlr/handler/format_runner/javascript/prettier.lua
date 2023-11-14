local M = {}

function M.format(ctx, path, stdout_collector)
  local content = require("cmdhndlr.lib.file").read_all(path)
  return ctx.job_factory:create({ "npx", "prettier", "--stdin-filepath", path }, {
    input = content,
    on_stdout = stdout_collector,
    as_job = true,
  })
end

M.working_dir_marker = require("cmdhndlr.util.working_dir").upward_marker(
  ".prettierrc",
  ".prettierrc.json",
  ".prettierrc.yml",
  ".prettierrc.yaml",
  ".prettierrc.json5",
  ".prettierrc.js",
  "prettier.config.js",
  ".prettierrc.mjs",
  "prettier.config.mjs",
  ".prettierrc.cjs",
  "prettier.config.cjs",
  ".prettierrc.toml"
)

return M
