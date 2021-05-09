local RunnerResult = require("cmdhndlr.core.runner_result").RunnerResult
local Handler = require("cmdhndlr.core.handler").Handler

local M = {}

local Runner = {}
M.Runner = Runner
Runner.handler_type = "runner"

function Runner.dispatch(Class, bufnr, name, ...)
  return Handler.dispatch(Class, bufnr, name, ...)
end

function Runner.new(bufnr, name, raw_working_dir, opts)
  vim.validate({bufnr = {bufnr, "number"}})

  local handler, err = Handler.new(Runner.handler_type, name, raw_working_dir, opts)
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
    return RunnerResult.new(err), nil
  end
  return RunnerResult.new(output), nil
end

function Runner._run_range(self, range)
  if not self.run_string then
    return nil, {msg = ("`%s` runner does not support range"):format(self.name)}
  end

  local str = table.concat(vim.api.nvim_buf_get_lines(self._bufnr, range.first - 1, range.last, false), "\n")
  return self:run_string(str)
end

function Runner._run_buffer(self)
  local path = vim.api.nvim_buf_get_name(self._bufnr)
  if path ~= "" then
    return self:run_file(path)
  end

  local range = {first = 1, last = vim.api.nvim_buf_line_count(self._bufnr)}
  return self:_run_range(range)
end

return M
