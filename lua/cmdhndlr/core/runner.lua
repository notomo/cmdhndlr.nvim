local RunnerResult = require("cmdhndlr.core.runner_result").RunnerResult
local Handler = require("cmdhndlr.core.handler").Handler

local M = {}

local Runner = {}
M.Runner = Runner
Runner.type = "runner"

function Runner.dispatch(Class, bufnr, name, opts)
  return Handler.dispatch(Class, bufnr, name, opts)
end

function Runner.new(bufnr, name, opts)
  vim.validate({bufnr = {bufnr, "number"}, name = {name, "string"}, opts = {opts, "table", true}})

  local handler, err = Handler.new(Runner.type, name, opts)
  if err ~= nil then
    return nil, err
  end

  local tbl = {_bufnr = bufnr, _handler = handler}
  return setmetatable(tbl, Runner)
end

function Runner.__index(self, k)
  return rawget(Runner, k) or self._handler[k]
end

function Runner.execute(self, range)
  local path = vim.api.nvim_buf_get_name(self._bufnr)

  local output, err
  if range ~= nil then
    local str = table.concat(vim.api.nvim_buf_get_lines(self._bufnr, range.first - 1, range.last, false), "\n")
    output, err = self:run_string(str)
  else
    output, err = self:run_file(path)
  end
  if err ~= nil then
    return nil, err
  end

  return RunnerResult.new(output)
end

return M
