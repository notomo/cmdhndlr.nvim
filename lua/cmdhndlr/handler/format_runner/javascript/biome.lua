local M = {}

M.opts = {
  extra_args = {},
}

function M.format(ctx, path, stdout_collector)
  local cmd = {
    "npx",
    "biome",
    "check",
    "--write",
    "--formatter-enabled=true",
    "--linter-enabled=true",
    "--stdin-file-path=" .. path,
  }
  vim.list_extend(cmd, ctx.opts.extra_args)

  local content = require("cmdhndlr.lib.file").read_all(path)
  return ctx.job_factory
    :create(cmd, {
      input = content,
      on_stdout = stdout_collector,
      as_job = true,
    })
    :next(function(result_ctx)
      -- workaround: ignore lint failure
      result_ctx.ok = true
      return result_ctx
    end)
end

M.working_dir_marker = require("cmdhndlr.util.working_dir").upward_marker("biome.json", "biome.jsonc")

return M
