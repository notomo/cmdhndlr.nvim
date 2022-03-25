local ReturnValue = require("cmdhndlr.vendor.misclib.error_handler").for_return_value()
local ShowError = require("cmdhndlr.vendor.misclib.error_handler").for_show_error()
local Context = require("cmdhndlr.core.context").Context

local execute_runner = function(runner_factory, args, layout)
  local runner, err = runner_factory()
  if err ~= nil then
    return nil, err
  end

  local result, exec_err = runner:execute(unpack(args))
  if exec_err ~= nil then
    return nil, exec_err
  end
  require("cmdhndlr.view").open(result, runner.working_dir, layout)
  Context.set(runner.path, result, runner_factory, args)

  return result
end

function ReturnValue.run(raw_opts)
  local opts = require("cmdhndlr.core.option").RunOption.new(raw_opts)
  local runner_factory = function()
    return require("cmdhndlr.core.runner.normal_runner").NormalRunner.new(opts)
  end
  local range = require("cmdhndlr.lib.mode").visual_range()
  return execute_runner(runner_factory, { range }, opts.layout)
end

function ReturnValue.test(raw_opts)
  local opts = require("cmdhndlr.core.option").TestOption.new(raw_opts)
  local runner_factory = function()
    return require("cmdhndlr.core.runner.test_runner").TestRunner.new(opts)
  end
  return execute_runner(runner_factory, { opts.filter, opts.is_leaf }, opts.layout)
end

function ReturnValue.build(raw_opts)
  local opts = require("cmdhndlr.core.option").BuildOption.new(raw_opts)
  local runner_factory = function()
    return require("cmdhndlr.core.runner.build_runner").BuildRunner.new(opts)
  end
  return execute_runner(runner_factory, {}, opts.layout)
end

function ReturnValue.retry()
  local ctx, err = Context.get()
  if err then
    return nil, err
  end
  return execute_runner(ctx.runner_factory, ctx.args, { type = "no" })
end

function ShowError.input(text, raw_opts)
  vim.validate({ text = { text, "string" } })

  local opts = require("cmdhndlr.core.option").InputOption.new(raw_opts)
  local ctx, err = Context.find_running(opts.name)
  if err then
    return err
  end

  local input_err = ctx.result:input(text)
  if input_err ~= nil then
    return input_err
  end
  require("cmdhndlr.vendor.misclib.message").info(("sent to %s: %s"):format(ctx.name, text))

  return nil
end

function ShowError.setup(config)
  vim.validate({ config = { config, "table" } })
  return require("cmdhndlr.core.custom").set(config)
end

function ReturnValue.executed_runners()
  local items = {}
  for _, ctx in ipairs(Context.all()) do
    table.insert(items, {
      name = ctx.name,
      bufnr = ctx.bufnr,
      is_running = ctx.result:is_running(),
    })
  end
  return items
end

return vim.tbl_extend("force", ReturnValue:methods(), ShowError:methods())
