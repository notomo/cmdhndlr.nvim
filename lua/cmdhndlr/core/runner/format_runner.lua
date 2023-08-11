local Handler = require("cmdhndlr.core.runner.handler").Handler

local FormatRunner = {}
FormatRunner.__index = FormatRunner

function FormatRunner.new(opts)
  local handler, err = Handler.new("format_runner", opts)
  if err ~= nil then
    return nil, err
  end
  vim.validate({ format = { handler.format, "function" } })

  local tbl = {
    working_dir = handler.working_dir,
    path = handler.path,
    _bufnr = opts.bufnr,
    _handler = handler,
  }
  return setmetatable(tbl, FormatRunner)
end

function FormatRunner.execute(self, observer)
  local path = vim.api.nvim_buf_get_name(self._bufnr)
  local stdout = require("cmdhndlr.vendor.misclib.job.output").new()
  local runner = self._handler:runner(observer)
  return self._handler.format(runner, path, stdout:collector()):next(function(...)
    local lines = stdout:lines()
    vim.api.nvim_buf_set_lines(self._bufnr, 0, -1, false, lines)
    return ...
  end)
end

return FormatRunner
