local RunnerResult = require("cmdhndlr.core.runner_result").RunnerResult
local Handler = require("cmdhndlr.core.handler").Handler

local M = {}

local TestRunner = {}
M.TestRunner = TestRunner
TestRunner.handler_type = "test_runner"

function TestRunner.dispatch(Class, ...)
  return Handler.dispatch(Class, ...)
end

function TestRunner.new(bufnr, ...)
  vim.validate({bufnr = {bufnr, "number"}})

  local handler, err = Handler.new(TestRunner.handler_type, ...)
  if err ~= nil then
    return nil, err
  end

  local tbl = {_bufnr = bufnr, _handler = handler}
  return setmetatable(tbl, TestRunner)
end

function TestRunner.__index(self, k)
  return rawget(TestRunner, k) or self._handler[k]
end

function TestRunner.execute(self)
  local path = vim.api.nvim_buf_get_name(self._bufnr)
  local output, err = self:run_file(path)
  if err ~= nil then
    return RunnerResult.error(self.hooks, err), nil
  end
  return RunnerResult.ok(self.hooks, output), nil
end

return M
