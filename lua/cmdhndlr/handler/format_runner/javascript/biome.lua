local M = {}

M.opts = {
  extra_args = {},
}

function M.format(ctx, path)
  local cmd = {
    "npx",
    "biome",
    "check",
    "--write",
    "--formatter-enabled=true",
    "--linter-enabled=true",
  }
  vim.list_extend(cmd, ctx.opts.extra_args)
  table.insert(cmd, path)

  return ctx.job_factory
    :create(cmd, {
      as_job = true,
    })
    :next(function(result_ctx)
      -- workaround: ignore lint failure
      result_ctx.ok = true
      result_ctx.reload = true
      return result_ctx
    end)
end

M.working_dir_marker = require("cmdhndlr.util.working_dir").upward_marker("biome.json", "biome.jsonc")

return M
