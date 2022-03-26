local Handler = require("cmdhndlr.core.runner.handler").Handler

local M = {}

local NormalRunner = {}
M.NormalRunner = NormalRunner

function NormalRunner.new(opts)
  local handler, err = Handler.new("normal_runner", opts)
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

  local output, err
  if range ~= nil then
    output, err = self:_run_range(range)
  else
    output, err = self:_run_buffer()
  end

  return output, err
end

function NormalRunner._run_range(self, range)
  if not self.run_string then
    return nil, ("`%s` runner does not support range"):format(self.name)
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

return M
