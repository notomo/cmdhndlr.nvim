local Handler = require("cmdhndlr.core.runner.handler")
local _limitter = require("cmdhndlr.lib.limitter").new(100, 500)

local FormatRunner = {}
FormatRunner.__index = FormatRunner

function FormatRunner.new(opts)
  local handler = Handler.new("format_runner", opts)
  if type(handler) == "string" then
    local err = handler
    return err
  end
  vim.validate("format", handler.format, "function")

  local tbl = {
    working_dir = handler.decided_working_dir,
    full_name = handler.full_name,
    _bufnr = opts.bufnr,
    _handler = handler,
    _global_opts = opts,
  }
  return setmetatable(tbl, FormatRunner)
end

function FormatRunner.execute(self, observer)
  local path = self._handler.path_modifier(vim.api.nvim_buf_get_name(self._bufnr))
  local stdout = require("cmdhndlr.lib.job.output").new()
  local ctx = require("cmdhndlr.core.runner.context").new(self._handler, self._global_opts, observer)
  return _limitter:enqueue(function()
    return self._handler.format(ctx, path, stdout:collector()):next(function(result_ctx)
      if not result_ctx.ok then
        return result_ctx
      end

      if result_ctx.reload then
        vim.cmd.checktime(self._bufnr)
      else
        local restore_cursor = require("cmdhndlr.lib.cursor").store_positions(self._bufnr)
        local lines = stdout:lines()
        vim.api.nvim_buf_set_lines(self._bufnr, 0, -1, false, lines)
        restore_cursor()
      end

      return result_ctx
    end)
  end)
end

return FormatRunner
