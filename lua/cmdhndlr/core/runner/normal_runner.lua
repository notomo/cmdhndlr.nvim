local Handler = require("cmdhndlr.core.runner.handler").Handler

local NormalRunner = {}

function NormalRunner.new(observer, opts)
  local handler, err = Handler.new("normal_runner", observer, opts)
  if err ~= nil then
    return nil, err
  end
  vim.validate({
    run_file = { handler.run_file, "function" },
    run_string = { handler.run_string, "function", true },
  })

  local tbl = { _bufnr = opts.bufnr, _handler = handler }
  return setmetatable(tbl, NormalRunner)
end

function NormalRunner.__index(self, k)
  return rawget(NormalRunner, k) or self._handler[k]
end

function NormalRunner.execute(self, range)
  vim.validate({ range = { range, "table", true } })
  if range ~= nil then
    return self:_run_range(range)
  end
  return self:_run_buffer()
end

function NormalRunner._run_range(self, range)
  if not self.run_string then
    local err = ("`%s` runner does not support range"):format(self.name)
    return require("cmdhndlr.vendor.promise").reject(err)
  end

  local str = require("cmdhndlr.lib.buffer_range").new(self._bufnr, range):to_string()
  return self:run_string(str)
end

function NormalRunner._run_buffer(self)
  local path = vim.api.nvim_buf_get_name(self._bufnr)
  if path ~= "" then
    return self:run_file(path)
  end

  local str = require("cmdhndlr.lib.buffer_range").entire(self._bufnr):to_string()
  if self.run_string then
    return self:run_string(str)
  end

  return self:run_file(self.filelib.temporary(str))
end

return NormalRunner
