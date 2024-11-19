local M = {}

function M.build(ctx, path)
  return ctx.job_factory:create({ "npx", "tsc", "--noEmit", path })
end

function M.build_as_job(ctx, path)
  local stdout = require("cmdhndlr.vendor.misclib.job.output").new()
  local working_dir_path = ctx.working_dir:get()
  return ctx.job_factory
    :create({ "npx", "tsc", "--pretty", "false", "--noEmit", path }, {
      as_job = true,
      on_stdout = stdout:collector(),
    })
    :next(function(ok)
      local lines = stdout:lines()
      local parsed = vim
        .iter(lines)
        :map(function(line)
          local err_path, row, column, message = line:match("([^(]+)%((%d+),(%d+)%): (.+)")
          if not err_path then
            return nil
          end
          return {
            path = vim.fs.joinpath(working_dir_path, err_path),
            row = tonumber(row),
            column = tonumber(column),
            message = message,
          }
        end)
        :totable()
      return ok, { errors = parsed }
    end)
end

M.working_dir_marker = require("cmdhndlr.util.working_dir").upward_marker("tsconfig.json")

return M
