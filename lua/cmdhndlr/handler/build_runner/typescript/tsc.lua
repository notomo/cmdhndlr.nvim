local M = {}

function M.build(ctx, path)
  return ctx.job_factory:create({ "npx", "tsc", "--noEmit", path })
end

function M.build_as_job(ctx, stdout_collector)
  local working_dir_path = ctx.working_dir:get()

  local parse = function(line)
    local path, row, column, message = line:match("([^(]+)%((%d+),(%d+)%): (.+)")
    if not path then
      return nil
    end
    return {
      path = vim.fs.joinpath(working_dir_path, path),
      row = tonumber(row),
      column = tonumber(column),
      message = message,
    }
  end

  return ctx.job_factory
    :create({ "npx", "tsc", "--pretty", "false", "--noEmit" }, {
      as_job = true,
      on_stdout = stdout_collector,
    })
    :next(function(ok)
      return ok, parse
    end)
end

M.working_dir_marker = require("cmdhndlr.util.working_dir").upward_marker("tsconfig.json")

return M
