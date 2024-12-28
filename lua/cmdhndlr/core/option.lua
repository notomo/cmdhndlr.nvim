local M = {}

local default = {
  bufnr = 0,
  name = nil,
  working_dir = function()
    return nil
  end,
  working_dir_marker = function()
    return nil
  end,
  path_modifier = function(path)
    return path
  end,
  env = {},
  hooks = {
    success = function() end,
    failure = function() end,
    pre_execute = require("cmdhndlr.util.hook").echo_cmd(),
    post_execute = function() end,
  },
  runner_opts = {},
  layout = { type = "horizontal" },
  build_cmd = function(default_cmd, callback)
    callback(default_cmd)
  end,
  reuse_predicate = function(_)
    return false
  end,
}

local new = function(defalt_opts, raw_opts, typ)
  raw_opts = raw_opts or {}

  local bufnr = raw_opts.bufnr or 0
  if bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end

  local filetype = vim.bo[bufnr].filetype
  local global = require("cmdhndlr.core.custom").config
  local global_name = global[typ].default[filetype]

  local buffer_local = vim.b[bufnr].cmdhndlr or {}
  local buffer_local_all = buffer_local["_"] or {}
  local buffer_local_type_specific = buffer_local[typ] or {}

  local name = raw_opts.name or buffer_local_type_specific.name or global_name or ""
  local custom_opts_all = vim.tbl_get(global.opts, "_") or {}
  local custom_opts_type_specific = vim.tbl_get(global.opts, typ, "_") or {}
  local custom_opts_runner_specific = vim.tbl_get(global.opts, typ, name) or {}
  local opts = vim.tbl_deep_extend(
    "force",
    defalt_opts,
    custom_opts_all,
    custom_opts_type_specific,
    custom_opts_runner_specific,
    buffer_local_all,
    buffer_local_type_specific,
    raw_opts,
    {
      name = name,
      bufnr = bufnr,
    }
  )

  if opts.name == "" then
    return "no handler"
  end

  opts.hooks = require("cmdhndlr.core.hooks").new(opts.hooks)

  return opts
end

local RunOption = {}
M.RunOption = RunOption
RunOption.default = vim.deepcopy(default)
function RunOption.new(raw_opts)
  return new(RunOption.default, raw_opts, "normal_runner")
end

local TestOption = {}
M.TestOption = TestOption
TestOption.default = vim.deepcopy(default)
TestOption.default.hooks = {
  success = require("cmdhndlr.util.hook").echo_success(),
  failure = require("cmdhndlr.util.hook").echo_failure(),
  pre_execute = require("cmdhndlr.util.hook").echo_cmd(),
  post_execute = function() end,
}
TestOption.default.filter = ""
TestOption.default.is_leaf = false
function TestOption.new(raw_opts)
  return new(TestOption.default, raw_opts, "test_runner")
end

local BuildOption = {}
M.BuildOption = BuildOption
M.BuildOption.default = vim.deepcopy(default)
BuildOption.default.hooks = {
  success = require("cmdhndlr.util.hook").echo_success(),
  failure = require("cmdhndlr.util.hook").echo_failure(),
  pre_execute = require("cmdhndlr.util.hook").echo_cmd(),
  post_execute = function() end,
}
function BuildOption.new(raw_opts)
  return new(BuildOption.default, raw_opts, "build_runner")
end

local BuildAsJobOption = {}
M.BuildAsJobOption = BuildAsJobOption
M.BuildAsJobOption.default = vim.deepcopy(default)
BuildAsJobOption.default.as_job = true
function BuildAsJobOption.new(raw_opts)
  return new(BuildAsJobOption.default, raw_opts, "build_runner")
end

local FormatOption = {}
M.FormatOption = FormatOption
M.FormatOption.default = vim.deepcopy(default)
FormatOption.default.hooks = {
  success = require("cmdhndlr.util.hook").echo_success(),
  failure = require("cmdhndlr.util.hook").echo_failure(),
  pre_execute = require("cmdhndlr.util.hook").echo_cmd(),
  post_execute = function() end,
}
function FormatOption.new(raw_opts)
  return new(FormatOption.default, raw_opts, "format_runner")
end

local InputOption = {}
M.InputOption = InputOption
M.InputOption.default = {
  full_name = nil,
}
function InputOption.new(raw_opts)
  raw_opts = raw_opts or {}
  return vim.tbl_deep_extend("force", M.InputOption.default, raw_opts)
end

local EnabledOption = {}
M.EnabledOption = EnabledOption
M.EnabledOption.default = vim.deepcopy(default)
function EnabledOption.new(typ, raw_opts)
  return new(EnabledOption.default, raw_opts, typ)
end

return M
