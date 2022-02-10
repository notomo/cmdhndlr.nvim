local ReturnValue = require("cmdhndlr.lib.error_handler").for_return_value()
local ReturnError = require("cmdhndlr.lib.error_handler").for_return_error()

local Context = require("cmdhndlr.core.context").Context
local NormalRunner = require("cmdhndlr.core.normal_runner").NormalRunner
local TestRunner = require("cmdhndlr.core.test_runner").TestRunner
local BuildRunner = require("cmdhndlr.core.build_runner").BuildRunner
local Hooks = require("cmdhndlr.core.hook").Hooks
local View = require("cmdhndlr.view").View
local hookutil = require("cmdhndlr.util.hook")

function ReturnValue.run(opts)
  vim.validate({ opts = { opts, "table", true } })
  opts = opts or {}

  local bufnr = vim.api.nvim_get_current_buf()
  local hooks = Hooks.from(opts.hooks)
  local runner_factory = function()
    return NormalRunner.new(
      bufnr,
      opts.name,
      hooks,
      opts.working_dir,
      opts.working_dir_marker,
      opts.env,
      opts.runner_opts
    )
  end

  local runner, err = runner_factory()
  if err ~= nil then
    return nil, err
  end

  local range = require("cmdhndlr.lib.mode").visual_range()
  local result, exec_err = runner:execute(range)
  if exec_err ~= nil then
    return nil, exec_err
  end
  View.open(result, runner.working_dir, opts.layout)
  Context.set(runner.path, result, runner_factory, { range })

  return result:return_output()
end

function ReturnValue.test(opts)
  vim.validate({ opts = { opts, "table", true } })
  opts = opts or {}

  local bufnr = vim.api.nvim_get_current_buf()
  local hooks = Hooks.from(opts.hooks, {
    success = hookutil.echo_success(),
    failure = hookutil.echo_failure(),
  })
  local runner_factory = function()
    return TestRunner.new(
      bufnr,
      opts.name,
      hooks,
      opts.working_dir,
      opts.working_dir_marker,
      opts.env,
      opts.runner_opts
    )
  end

  local runner, err = runner_factory()
  if err ~= nil then
    return nil, err
  end

  local result, exec_err = runner:execute(opts.filter)
  if exec_err ~= nil then
    return nil, exec_err
  end
  View.open(result, runner.working_dir, opts.layout)
  Context.set(runner.path, result, runner_factory, { opts.filter })

  return result:return_output()
end

function ReturnValue.build(opts)
  vim.validate({ opts = { opts, "table", true } })
  opts = opts or {}

  local bufnr = vim.api.nvim_get_current_buf()
  local hooks = Hooks.from(opts.hooks, {
    success = hookutil.echo_success(),
    failure = hookutil.echo_failure(),
  })
  local runner_factory = function()
    return BuildRunner.new(
      bufnr,
      opts.name,
      hooks,
      opts.working_dir,
      opts.working_dir_marker,
      opts.env,
      opts.runner_opts
    )
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
  Context.set(runner.path, result, runner_factory)

  return result:return_output()
end

function ReturnValue.retry()
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
  View.open(result, runner.working_dir, { type = "no" })
  Context.set(runner.path, result, ctx.runner_factory, ctx.args)

  return result:return_output()
end

function ReturnError.input(text, opts)
  vim.validate({ text = { text, "string" }, opts = { opts, "table", true } })
  opts = opts or {}

  local ctx, err = Context.find(opts.name, function(ctx)
    return ctx.result:is_running()
  end)
  if err then
    return "not found running buffer: " .. err
  end

  local input_err = ctx.result:input(text)
  if input_err ~= nil then
    return input_err
  end
  require("cmdhndlr.lib.message").echo(("sent to %s: %s"):format(ctx.name, text))

  return nil
end

function ReturnError.delete(bufnr)
  return Context.delete_from(bufnr)
end

function ReturnError.setup(config)
  vim.validate({ config = { config, "table" } })
  return require("cmdhndlr.core.custom").set(config)
end

function ReturnValue.executed_runners()
  local items = {}
  for _, ctx in ipairs(Context.all()) do
    table.insert(items, { name = ctx.name, bufnr = ctx.bufnr, is_running = ctx.result:is_running() })
  end
  return items
end

return vim.tbl_extend("force", ReturnValue:methods(), ReturnError:methods())
