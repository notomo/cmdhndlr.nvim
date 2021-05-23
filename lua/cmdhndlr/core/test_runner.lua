local RunnerResult = require("cmdhndlr.core.runner_result").RunnerResult
local Handler = require("cmdhndlr.core.handler").Handler

local M = {}

local TestRunner = {}
M.TestRunner = TestRunner

function TestRunner.new(bufnr, ...)
  local handler, err = Handler.new("test_runner", bufnr, ...)
  if err ~= nil then
    return nil, err
  end
  vim.validate({run_file = {handler.run_file, "function"}})

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
