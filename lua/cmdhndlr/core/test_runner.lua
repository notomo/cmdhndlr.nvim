local Handler = require("cmdhndlr.core.handler").Handler
local Parser = require("cmdhndlr.core.parser").Parser
local TableJoiner = require("cmdhndlr.lib.table_joiner").TableJoiner
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
    TableJoiner = TableJoiner,
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

  return self:result(output, err)
end

return M
