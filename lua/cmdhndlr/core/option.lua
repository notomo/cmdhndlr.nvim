local M = {}

local default = {
  bufnr = 0,
  name = "",
  working_dir = function()
    return nil
  end,
  working_dir_marker = function()
    return nil
  end,
  env = {},
  hooks = {
    success = function() end,
    failure = function() end,
    pre_execute = require("cmdhndlr.util.hook").echo_cmd(),
  },
  runner_opts = {},
  layout = { type = "horizontal" },
}

local new = function(defalt_opts, raw_opts)
  vim.validate({ raw_opts = { raw_opts, "table", true } })
  raw_opts = raw_opts or {}
  local opts = vim.tbl_deep_extend("force", defalt_opts, raw_opts)

  if opts.bufnr == 0 then
    opts.bufnr = vim.api.nvim_get_current_buf()
  end
  opts.runner_opts = vim.tbl_deep_extend("force", opts.runner_opts, vim.b[opts.bufnr].cmdhndlr_runner_opts or {})

  opts.hooks = require("cmdhndlr.core.hooks").new(opts.hooks)

  return opts
end

local RunOption = {}
M.RunOption = RunOption
RunOption.default = vim.deepcopy(default)
function RunOption.new(raw_opts)
  return new(RunOption.default, raw_opts)
end

local TestOption = {}
M.TestOption = TestOption
TestOption.default = vim.deepcopy(default)
TestOption.default.hooks = {
  success = require("cmdhndlr.util.hook").echo_success(),
  failure = require("cmdhndlr.util.hook").echo_failure(),
  pre_execute = require("cmdhndlr.util.hook").echo_cmd(),
}
TestOption.default.filter = ""
TestOption.default.is_leaf = false
function TestOption.new(raw_opts)
  return new(TestOption.default, raw_opts)
end

local BuildOption = {}
M.BuildOption = BuildOption
M.BuildOption.default = vim.deepcopy(default)
BuildOption.default.hooks = {
  success = require("cmdhndlr.util.hook").echo_success(),
  failure = require("cmdhndlr.util.hook").echo_failure(),
  pre_execute = require("cmdhndlr.util.hook").echo_cmd(),
}
function BuildOption.new(raw_opts)
  return new(BuildOption.default, raw_opts)
end

local InputOption = {}
M.InputOption = InputOption
M.InputOption.default = {
  name = nil,
}
function InputOption.new(raw_opts)
  vim.validate({ raw_opts = { raw_opts, "table", true } })
  raw_opts = raw_opts or {}
  return vim.tbl_deep_extend("force", M.InputOption.default, raw_opts)
end

return M
