local RunnerResult = require("cmdhndlr.core.runner_result").RunnerResult
local BufferRange = require("cmdhndlr.core.buffer_range").BufferRange
local Handler = require("cmdhndlr.core.handler").Handler

local M = {}

local Runner = {}
M.Runner = Runner
Runner.handler_type = "runner"

function Runner.dispatch(Class, ...)
  return Handler.dispatch(Class, ...)
end

function Runner.new(bufnr, ...)
  vim.validate({bufnr = {bufnr, "number"}})

  local handler, err = Handler.new(Runner.handler_type, ...)
  if err ~= nil then
    return nil, err
  end
  vim.validate({
    run_file = {handler.run_file, "function"},
    run_string = {handler.run_string, "function", true},
  })

  local tbl = {_bufnr = bufnr, _handler = handler}
  return setmetatable(tbl, Runner)
end

function Runner.__index(self, k)
  return rawget(Runner, k) or self._handler[k]
end

function Runner.execute(self, range)
  vim.validate({range = {range, "table", true}})

  local output, err
  if range ~= nil then
    output, err = self:_run_range(range)
  else
    output, err = self:_run_buffer()
  end

  if err ~= nil then
    if type(err) == "table" then
      return nil, err.msg
    end
    return RunnerResult.error(self.hooks, err), nil
  end
  return RunnerResult.ok(self.hooks, output), nil
end

function Runner._run_range(self, range)
  if not self.run_string then
    return nil, {msg = ("`%s` runner does not support range"):format(self.name)}
  end

  local str = BufferRange.new(self._bufnr, range):to_string()
  return self:run_string(str)
end

function Runner._run_buffer(self)
  local path = vim.api.nvim_buf_get_name(self._bufnr)
  if path ~= "" then
    return self:run_file(path)
  end

  local str = BufferRange.entire(self._bufnr):to_string()
  if self.run_string then
    return self:run_string(str)
  end

  return self:run_file(self.filelib.temporary(str))
end

return M
