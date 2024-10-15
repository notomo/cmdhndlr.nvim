local M = {}

function M.format(ctx, path)
  return ctx.job_factory
    :create({
      "npx",
      "biome",
      "check",
      "--write",
      "--unsafe",
      "--organize-imports-enabled=true",
      "--formatter-enabled=true",
      "--linter-enabled=true",
      path,
    }, {
      as_job = true,
    })
    :next(function()
      -- workaround: ignore lint failure
      return true, true
    end)
end

M.working_dir_marker = require("cmdhndlr.util.working_dir").upward_marker("biome.json", "biome.jsonc")

return M
