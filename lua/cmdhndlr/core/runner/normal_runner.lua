local Handler = require("cmdhndlr.core.runner.handler")
local filelib = require("cmdhndlr.lib.file")

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
    working_dir = handler.decided_working_dir,
    path = handler.path,
    _bufnr = opts.bufnr,
    _handler = handler,
    _global_opts = opts,
  }
  return setmetatable(tbl, NormalRunner)
end

function NormalRunner.execute(self, observer, range)
  vim.validate({ range = { range, "table", true } })
  local ctx = require("cmdhndlr.core.runner.context").new(self._handler, self._global_opts, observer)
  if range ~= nil then
    return self:_run_range(ctx, range)
  end
  return self:_run_buffer(ctx)
end

function NormalRunner._run_range(self, ctx, range)
  if not self._handler.run_string then
    local err = ("`%s` runner does not support range"):format(self._handler.name)
    return require("cmdhndlr.vendor.promise").reject(err)
  end

  local str = require("cmdhndlr.lib.buffer_range").new(self._bufnr, range):to_string()
  return self._handler.run_string(ctx, str)
end

function NormalRunner._run_buffer(self, ctx)
  local path = vim.api.nvim_buf_get_name(self._bufnr)
  if path ~= "" then
    return self._handler.run_file(ctx, path)
  end

  local str = require("cmdhndlr.lib.buffer_range").entire(self._bufnr):to_string()
  if self._handler.run_string then
    return self._handler.run_string(ctx, str)
  end

  return self._handler.run_file(ctx, filelib.temporary(str))
end

return NormalRunner
