local Context = require("cmdhndlr.core.context").Context
local NormalRunner = require("cmdhndlr.core.normal_runner").NormalRunner
local TestRunner = require("cmdhndlr.core.test_runner").TestRunner
local BuildRunner = require("cmdhndlr.core.build_runner").BuildRunner
local Hooks = require("cmdhndlr.core.hook").Hooks
local ExecuteScope = require("cmdhndlr.core.execute_scope").ExecuteScope
local custom = require("cmdhndlr.core.custom")
local View = require("cmdhndlr.view").View
local messagelib = require("cmdhndlr.lib.message")
local modelib = require("cmdhndlr.lib.mode")
local hookutil = require("cmdhndlr.util.hook")

local M = {}

local Command = {}
Command.__index = Command
M.Command = Command

function Command.new(name, ...)
  local args = {...}
  local f = function()
    return Command[name](unpack(args))
  end

  local ok, result, msg = xpcall(f, debug.traceback)
  if not ok then
    return messagelib.error(result)
  elseif msg then
    return messagelib.warn(msg)
  end
  return result
end

function Command.run(opts)
  vim.validate({opts = {opts, "table", true}})
  opts = opts or {}

  local bufnr = vim.api.nvim_get_current_buf()
  local hooks = Hooks.from(opts.hooks)
  local runner_factory = function()
    return NormalRunner.new(bufnr, opts.name, hooks, opts.working_dir, opts.runner_opts)
  end

  local runner, err = runner_factory()
  if err ~= nil then
    return nil, err
  end

  local range = modelib.visual_range()
  local result, exec_err = runner:execute(range)
  if exec_err ~= nil then
    return nil, exec_err
  end
  View.open(result, runner.working_dir, opts.layout)
  Context.set(result.bufnr, runner_factory, {range})

  return result:return_output()
end

function Command.test(opts)
  vim.validate({opts = {opts, "table", true}})
  opts = opts or {}

  local bufnr = vim.api.nvim_get_current_buf()
  local hooks = Hooks.from(opts.hooks, {
    success = hookutil.echo_success(),
    failure = hookutil.echo_failure(),
  })
  local runner_factory = function()
    return TestRunner.new(bufnr, opts.name, hooks, opts.working_dir, opts.runner_opts)
  end

  local runner, err = runner_factory()
  if err ~= nil then
    return nil, err
  end

  local scope = ExecuteScope.new(opts.scope)
  local result, exec_err = runner:execute(scope)
  if exec_err ~= nil then
    return nil, exec_err
  end
  View.open(result, runner.working_dir, opts.layout)
  Context.set(result.bufnr, runner_factory, {scope})

  return result:return_output()
end

function Command.build(opts)
  vim.validate({opts = {opts, "table", true}})
  opts = opts or {}

  local bufnr = vim.api.nvim_get_current_buf()
  local hooks = Hooks.from(opts.hooks, {
    success = hookutil.echo_success(),
    failure = hookutil.echo_failure(),
  })
  local runner_factory = function()
    return BuildRunner.new(bufnr, opts.name, hooks, opts.working_dir, opts.runner_opts)
  end

  local runner, err = runner_factory()
  if err ~= nil then
    return nil, err
  end

  local result, exec_err = runner:execute()
  if exec_err ~= nil then
    return nil, exec_err
  end
  View.open(result, runner.working_dir, opts.layout)
  Context.set(result.bufnr, runner_factory)

  return result:return_output()
end

function Command.retry()
  local ctx, err = Context.get()
  if err then
    return nil, "not cmdhndlr buffer: " .. err
  end

  local runner, factory_err = ctx.runner_factory()
  if factory_err ~= nil then
    return nil, factory_err
  end

  local result, exec_err = runner:execute(unpack(ctx.args))
  if exec_err ~= nil then
    return nil, exec_err
  end
  View.open(result, runner.working_dir, {type = "no"})
  Context.set(result.bufnr, ctx.runner_factory, ctx.args)

  return result:return_output()
end

function Command.delete(bufnr)
  return nil, Context.delete_from(bufnr)
end

function Command.setup(config)
  vim.validate({config = {config, "table"}})
  custom.set(config)
end

return M
