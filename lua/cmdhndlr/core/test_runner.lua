local RunnerResult = require("cmdhndlr.core.runner_result").RunnerResult
local Handler = require("cmdhndlr.core.handler").Handler
local Parser = require("cmdhndlr.core.parser").Parser
local NodeJointer = require("cmdhndlr.core.parser").NodeJointer
local StringUnwrapper = require("cmdhndlr.lib.string_unwrapper").StringUnwrapper

local M = {}

local TestRunner = {}
M.TestRunner = TestRunner

function TestRunner.new(bufnr, ...)
  local handler, err = Handler.new("test_runner", bufnr, ...)
  if err ~= nil then
    return nil, err
  end
  vim.validate({
    run_file = {handler.run_file, "function"},
    run_position_scope = {handler.run_position_scope, "function", true},
  })

  local tbl = {
    _bufnr = bufnr,
    _handler = handler,
    parser = Parser.new(bufnr),
    NodeJointer = NodeJointer,
    StringUnwrapper = StringUnwrapper,
  }
  return setmetatable(tbl, TestRunner)
end

function TestRunner.__index(self, k)
  return rawget(TestRunner, k) or self._handler[k]
end

function TestRunner.execute(self, scope)
  vim.validate({scope = {scope, "table", true}})
  local path = vim.api.nvim_buf_get_name(self._bufnr)

  local output, err
  if scope.cursor then
    output, err = self:run_position_scope(path, scope.cursor)
  else
    output, err = self:run_file(path)
  end

  if err ~= nil then
    return RunnerResult.error(self.hooks, err), nil
  end
  return RunnerResult.ok(self.hooks, output), nil
end

return M
