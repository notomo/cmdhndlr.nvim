local ReturnValue = require("cmdhndlr.vendor.misclib.error_handler").for_return_value()
local ShowError = require("cmdhndlr.vendor.misclib.error_handler").for_show_error()
local Context = require("cmdhndlr.core.context")

local execute_runner = function(runner_factory, args, layout, hooks)
  local runner, factory_err = runner_factory()
  if factory_err ~= nil then
    return nil, factory_err
  end

  local bufnr = vim.api.nvim_create_buf(false, true)
  local observer = {
    pre_start = function(cmd)
      hooks.pre_execute(cmd)
      require("cmdhndlr.view").open(bufnr, runner.working_dir, layout)
    end,
    post_start = function(job)
      Context.set(runner.path, bufnr, job, runner_factory, args, hooks)
    end,
  }

  local info_factory = hooks:info_factory()
  return runner
    :execute(observer, unpack(args))
    :next(function(ok)
      local info = info_factory()
      if ok then
        hooks.success(info)
      else
        hooks.failure(info)
      end
      vim.bo[bufnr].bufhidden = "wipe"
    end)
    :catch(function(err)
      require("cmdhndlr.vendor.misclib.message").warn(err)
    end)
end

function ReturnValue.run(raw_opts)
  local opts = require("cmdhndlr.core.option").RunOption.new(raw_opts)
  local runner_factory = function()
    return require("cmdhndlr.core.runner.normal_runner").new(opts)
  end
  local range = require("cmdhndlr.vendor.misclib.visual_mode").row_range()
  return execute_runner(runner_factory, { range }, opts.layout, opts.hooks)
end

function ReturnValue.test(raw_opts)
  local opts = require("cmdhndlr.core.option").TestOption.new(raw_opts)
  local runner_factory = function()
    return require("cmdhndlr.core.runner.test_runner").new(opts)
  end
  return execute_runner(runner_factory, { opts.filter, opts.is_leaf }, opts.layout, opts.hooks)
end

function ReturnValue.build(raw_opts)
  local opts = require("cmdhndlr.core.option").BuildOption.new(raw_opts)
  local runner_factory = function()
    return require("cmdhndlr.core.runner.build_runner").new(opts)
  end
  return execute_runner(runner_factory, {}, opts.layout, opts.hooks)
end

function ReturnValue.retry()
  local ctx, err = Context.get()
  if err then
    return nil, err
  end
  return execute_runner(ctx.runner_factory, ctx.args, { type = "no" }, ctx.hooks)
end

function ShowError.input(text, raw_opts)
  vim.validate({ text = { text, "string" } })

  local opts = require("cmdhndlr.core.option").InputOption.new(raw_opts)
  local ctx, err = Context.find_running(opts.name)
  if err then
    return err
  end

  local input_err = ctx.job:input(text)
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
      is_running = ctx.job:is_running(),
    })
  end
  return items
end

function ReturnValue.execute(name, raw_opts)
  raw_opts = raw_opts or {}
  if vim.startswith(name, "normal_runner/") then
    raw_opts.name = name:gsub("^normal_runner/", "")
    return ReturnValue.run(raw_opts)
  end
  if vim.startswith(name, "test_runner/") then
    raw_opts.name = name:gsub("^test_runner/", "")
    return ReturnValue.test(raw_opts)
  end
  if vim.startswith(name, "build_runner/") then
    raw_opts.name = name:gsub("^build_runner/", "")
    return ReturnValue.build(raw_opts)
  end
  error("unexpected runner name: " .. name)
end

function ReturnValue.runners()
  local items = {}
  for _, name in ipairs(require("cmdhndlr.core.runner.handler").all()) do
    table.insert(items, { name = name })
  end
  return items
end

return vim.tbl_extend("force", ReturnValue:methods(), ShowError:methods())
