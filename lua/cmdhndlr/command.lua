local M = {}

local State = require("cmdhndlr.core.state")

local execute_runner = function(runner_factory, args, layout, hooks)
  local runner, factory_err = runner_factory()
  if factory_err then
    require("cmdhndlr.vendor.misclib.message").error(factory_err)
  end

  local bufnr = vim.api.nvim_create_buf(false, true)
  local observer = {
    pre_start = function(cmd)
      hooks.pre_execute(cmd)
      require("cmdhndlr.view").open(bufnr, runner.working_dir, layout)
    end,
    post_start = function(job)
      State.set(runner.path, bufnr, job, runner_factory, args, hooks)
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

function M.run(raw_opts)
  local opts, err = require("cmdhndlr.core.option").RunOption.new(raw_opts)
  if err then
    require("cmdhndlr.vendor.misclib.message").error(err)
  end

  local runner_factory = function()
    return require("cmdhndlr.core.runner.normal_runner").new(opts)
  end
  local range = require("cmdhndlr.vendor.misclib.visual_mode").row_range()
  return execute_runner(runner_factory, { range }, opts.layout, opts.hooks)
end

function M.test(raw_opts)
  local opts, err = require("cmdhndlr.core.option").TestOption.new(raw_opts)
  if err then
    require("cmdhndlr.vendor.misclib.message").error(err)
  end

  local runner_factory = function()
    return require("cmdhndlr.core.runner.test_runner").new(opts)
  end
  return execute_runner(runner_factory, { opts.filter, opts.is_leaf }, opts.layout, opts.hooks)
end

function M.build(raw_opts)
  local opts, err = require("cmdhndlr.core.option").BuildOption.new(raw_opts)
  if err then
    require("cmdhndlr.vendor.misclib.message").error(err)
  end

  local runner_factory = function()
    return require("cmdhndlr.core.runner.build_runner").new(opts)
  end
  return execute_runner(runner_factory, {}, opts.layout, opts.hooks)
end

function M.format(raw_opts)
  local opts, err = require("cmdhndlr.core.option").FormatOption.new(raw_opts)
  if err then
    require("cmdhndlr.vendor.misclib.message").error(err)
  end

  local runner_factory = function()
    return require("cmdhndlr.core.runner.format_runner").new(opts)
  end
  return execute_runner(runner_factory, {}, nil, opts.hooks)
end

function M.retry()
  local state, err = State.get()
  if err then
    require("cmdhndlr.vendor.misclib.message").error(err)
  end
  return execute_runner(state.runner_factory, state.args, { type = "no" }, state.hooks)
end

function M.input(text, raw_opts)
  vim.validate({ text = { text, "string" } })

  local opts = require("cmdhndlr.core.option").InputOption.new(raw_opts)
  local state, err = State.find_running(opts.name)
  if err then
    require("cmdhndlr.vendor.misclib.message").error(err)
  end

  local input_err = state.job:input(text)
  if input_err then
    require("cmdhndlr.vendor.misclib.message").error(input_err)
  end
  require("cmdhndlr.vendor.misclib.message").info(("sent to %s: %s"):format(state.name, text))
end

function M.setup(config)
  vim.validate({ config = { config, "table" } })
  require("cmdhndlr.core.custom").set(config)
end

function M.executed_runners()
  local items = {}
  for _, state in ipairs(State.all()) do
    table.insert(items, {
      name = state.name,
      bufnr = state.bufnr,
      is_running = state.job:is_running(),
    })
  end
  return items
end

function M.execute(name, raw_opts)
  raw_opts = raw_opts or {}
  if vim.startswith(name, "normal_runner/") then
    raw_opts.name = name:gsub("^normal_runner/", "")
    return M.run(raw_opts)
  end
  if vim.startswith(name, "test_runner/") then
    raw_opts.name = name:gsub("^test_runner/", "")
    return M.test(raw_opts)
  end
  if vim.startswith(name, "build_runner/") then
    raw_opts.name = name:gsub("^build_runner/", "")
    return M.build(raw_opts)
  end
  if vim.startswith(name, "format_runner/") then
    raw_opts.name = name:gsub("^format_runner/", "")
    return M.format(raw_opts)
  end
  error("unexpected runner name: " .. name)
end

function M.enabled(typ, raw_opts)
  local opts, err = require("cmdhndlr.core.option").EnabledOption.new(typ, raw_opts)
  if err then
    if err == "no handler" then
      return false
    end
    require("cmdhndlr.vendor.misclib.message").error(err)
  end
  local _, handler_err = require("cmdhndlr.core.runner.handler").new(typ, opts)
  return handler_err == nil
end

function M.runners()
  return require("cmdhndlr.core.runner.handler").all()
end

return M
