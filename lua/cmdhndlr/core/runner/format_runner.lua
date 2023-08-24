local Handler = require("cmdhndlr.core.runner.handler")
local _limitter = require("cmdhndlr.lib.limitter").new(100, 500)

local FormatRunner = {}
FormatRunner.__index = FormatRunner

function FormatRunner.new(opts)
  local handler, err = Handler.new("format_runner", opts)
  if err ~= nil then
    return nil, err
  end
  vim.validate({ format = { handler.format, "function" } })

  local tbl = {
    working_dir = handler.decided_working_dir,
    path = handler.path,
    _bufnr = opts.bufnr,
    _handler = handler,
    _global_opts = opts,
  }
  return setmetatable(tbl, FormatRunner)
end

function FormatRunner.execute(self, observer)
  local path = vim.api.nvim_buf_get_name(self._bufnr)
  local stdout = require("cmdhndlr.vendor.misclib.job.output").new()
  local ctx = require("cmdhndlr.core.runner.context").new(self._handler, self._global_opts, observer)
  return _limitter:enqueue(function()
    return self._handler.format(ctx, path, stdout:collector()):next(function(ok)
      if ok then
        local lines = stdout:lines()
        local restore_cursor = require("cmdhndlr.lib.cursor").store_positions(self._bufnr)
        vim.api.nvim_buf_set_lines(self._bufnr, 0, -1, false, lines)
        restore_cursor()
      end
      return ok
    end)
  end)
end

return FormatRunner
