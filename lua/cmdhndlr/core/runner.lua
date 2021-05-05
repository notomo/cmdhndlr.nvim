local RunnerResult = require("cmdhndlr.core.runner_result").RunnerResult
local JobFactory = require("cmdhndlr.core.job_factory").JobFactory
local modulelib = require("cmdhndlr.lib.module")

local M = {}

local Runner = {}
M.Runner = Runner

function Runner.new(bufnr, name, opts)
  vim.validate({bufnr = {bufnr, "number"}, name = {name, "string"}, opts = {opts, "table", true}})

  local runner = modulelib.find("cmdhndlr.handler.runner." .. name)
  if not runner then
    return nil, "not found runner: " .. name
  end

  local tbl = {
    name = name,
    opts = vim.tbl_extend("force", runner.opts or {}, opts or {}),
    job_factory = JobFactory.new(),
    _bufnr = bufnr,
    _runner = runner,
  }
  return setmetatable(tbl, Runner)
end

function Runner.__index(self, k)
  return rawget(Runner, k) or self._runner[k]
end

function Runner.execute(self)
  local path = vim.api.nvim_buf_get_name(self._bufnr)
  local runner_output, err = self:run_file(path)
  if err ~= nil then
    return nil, err
  end
  return RunnerResult.new(runner_output)
end

Runner.default = {lua = "vim/lua", go = "go/go"}

function Runner.dispatch(bufnr, name, opts)
  vim.validate({
    bufnr = {bufnr, "number"},
    name = {name, "string", true},
    opts = {opts, "table", true},
  })

  if name ~= nil then
    return Runner.new(bufnr, name, opts)
  end

  local filetype = vim.bo[bufnr].filetype
  local default = Runner.default[filetype]
  if default ~= nil then
    return Runner.new(bufnr, default, opts)
  end

  return nil, "no runner"
end

return M
