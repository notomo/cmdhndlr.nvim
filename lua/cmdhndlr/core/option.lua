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
  hooks = {},
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

  opts.hooks = require("cmdhndlr.core.hook").from(opts.hooks)

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
}
TestOption.default.filter = ""
function TestOption.new(raw_opts)
  return new(TestOption.default, raw_opts)
end

local BuildOption = {}
M.BuildOption = BuildOption
M.BuildOption.default = vim.deepcopy(default)
BuildOption.default.hooks = {
  success = require("cmdhndlr.util.hook").echo_success(),
  failure = require("cmdhndlr.util.hook").echo_failure(),
}
function BuildOption.new(raw_opts)
  return new(BuildOption.default, raw_opts)
end

return M
