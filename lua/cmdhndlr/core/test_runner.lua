local RunnerResult = require("cmdhndlr.core.runner_result").RunnerResult
local JobFactory = require("cmdhndlr.core.job_factory").JobFactory
local modulelib = require("cmdhndlr.lib.module")

local M = {}

local TestRunner = {}
M.TestRunner = TestRunner

function TestRunner.new(bufnr, name, opts)
  vim.validate({bufnr = {bufnr, "number"}, name = {name, "string"}, opts = {opts, "table", true}})

  local runner = modulelib.find("cmdhndlr.handler.test_runner." .. name)
  if not runner then
    return nil, "not found test runner: " .. name
  end

  local tbl = {
    name = name,
    opts = vim.tbl_extend("force", runner.opts or {}, opts or {}),
    job_factory = JobFactory.new(),
    _bufnr = bufnr,
    _runner = runner,
  }
  return setmetatable(tbl, TestRunner)
end

function TestRunner.__index(self, k)
  return rawget(TestRunner, k) or self._runner[k]
end

function TestRunner.execute(self)
  local path = vim.api.nvim_buf_get_name(self._bufnr)
  local runner_output, err = self:run_file(path)
  if err ~= nil then
    return nil, err
  end
  return RunnerResult.new(runner_output)
end

TestRunner.default = {lua = "lua/busted"}

function TestRunner.dispatch(bufnr, name, opts)
  vim.validate({
    bufnr = {bufnr, "number"},
    name = {name, "string", true},
    opts = {opts, "table", true},
  })

  if name ~= nil then
    return TestRunner.new(bufnr, name, opts)
  end

  local filetype = vim.bo[bufnr].filetype
  local default = TestRunner.default[filetype]
  if default ~= nil then
    return TestRunner.new(bufnr, default, opts)
  end

  return nil, "no runner"
end

return M
