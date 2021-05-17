local RunnerResult = require("cmdhndlr.core.runner_result").RunnerResult
local Handler = require("cmdhndlr.core.handler").Handler

local M = {}

local BuildRunner = {}
M.BuildRunner = BuildRunner
BuildRunner.handler_type = "build_runner"

function BuildRunner.dispatch(Class, ...)
  return Handler.dispatch(Class, ...)
end

function BuildRunner.new(bufnr, ...)
  vim.validate({bufnr = {bufnr, "number"}})

  local handler, err = Handler.new(BuildRunner.handler_type, ...)
  if err ~= nil then
    return nil, err
  end
  vim.validate({build = {handler.build, "function"}})

  local tbl = {_bufnr = bufnr, _handler = handler}
  return setmetatable(tbl, BuildRunner)
end

function BuildRunner.__index(self, k)
  return rawget(BuildRunner, k) or self._handler[k]
end

function BuildRunner.execute(self)
  local path = vim.api.nvim_buf_get_name(self._bufnr)
  local output, err = self:build(path)
  if err ~= nil then
    return RunnerResult.error(self.hooks, err), nil
  end
  return RunnerResult.ok(self.hooks, output), nil
end

return M
