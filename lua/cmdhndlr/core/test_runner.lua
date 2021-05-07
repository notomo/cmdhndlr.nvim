local RunnerResult = require("cmdhndlr.core.runner_result").RunnerResult
local Handler = require("cmdhndlr.core.handler").Handler

local M = {}

local TestRunner = {}
M.TestRunner = TestRunner
TestRunner.default = {lua = "lua/busted"}

function TestRunner.dispatch(Class, bufnr, name, opts)
  return Handler.dispatch(Class, bufnr, name, opts)
end

function TestRunner.new(bufnr, name, opts)
  vim.validate({bufnr = {bufnr, "number"}, name = {name, "string"}, opts = {opts, "table", true}})

  local handler, err = Handler.new("test_runner", name, opts)
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
    return nil, err
  end
  return RunnerResult.new(output)
end

return M
