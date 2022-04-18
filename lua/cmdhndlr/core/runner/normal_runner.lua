local Handler = require("cmdhndlr.core.runner.handler").Handler

local NormalRunner = {}
NormalRunner.__index = NormalRunner

function NormalRunner.new(opts)
  local handler, err = Handler.new("normal_runner", opts)
  if err ~= nil then
    return nil, err
  end
  vim.validate({
    run_file = { handler.run_file, "function" },
    run_string = { handler.run_string, "function", true },
  })

  local tbl = {
    working_dir = handler.working_dir,
    path = handler.path,
    _bufnr = opts.bufnr,
    _handler = handler,
  }
  return setmetatable(tbl, NormalRunner)
end

function NormalRunner.execute(self, observer, range)
  vim.validate({ range = { range, "table", true } })
  local runner = self._handler:runner(observer)
  if range ~= nil then
    return self:_run_range(runner, range)
  end
  return self:_run_buffer(runner)
end

function NormalRunner._run_range(self, runner, range)
  if not self._handler.run_string then
    local err = ("`%s` runner does not support range"):format(self._handler.name)
    return require("cmdhndlr.vendor.promise").reject(err)
  end

  local str = require("cmdhndlr.lib.buffer_range").new(self._bufnr, range):to_string()
  return self._handler.run_string(runner, str)
end

function NormalRunner._run_buffer(self, runner)
  local path = vim.api.nvim_buf_get_name(self._bufnr)
  if path ~= "" then
    return self._handler.run_file(runner, path)
  end

  local str = require("cmdhndlr.lib.buffer_range").entire(self._bufnr):to_string()
  if self._handler.run_string then
    return self._handler.run_string(runner, str)
  end

  return self._handler.run_file(runner, runner.filelib.temporary(str))
end

return NormalRunner
