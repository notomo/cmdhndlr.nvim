local M = {}

local State = require("cmdhndlr.core.state")

local execute_runner = function(runner_factory, args, layout, hooks)
  local runner, factory_err = runner_factory()
  if factory_err then
    require("cmdhndlr.vendor.misclib.message").error(factory_err)
  end

  local bufnr = vim.api.nvim_create_buf(false, true)
  local window_id
  local observer = {
    pre_start = function(cmd)
      hooks.pre_execute(cmd)
      require("cmdhndlr.view").open(bufnr, runner.working_dir, layout)
      window_id = vim.api.nvim_get_current_win()
    end,
    post_start = function(job)
      State.set(runner.full_name, bufnr, job, runner_factory, args, hooks)
    end,
  }

  local info_factory = hooks:info_factory()
  return runner
    :execute(observer, unpack(args))
    :next(function(ok)
      local info = info_factory(window_id)
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
  local state, err = State.find_running(opts.full_name)
  if err then
    require("cmdhndlr.vendor.misclib.message").error(err)
  end

  local input_err = state.job:input(text)
  if input_err then
    require("cmdhndlr.vendor.misclib.message").error(input_err)
  end
  require("cmdhndlr.vendor.misclib.message").info(("sent to %s: %s"):format(state.full_name, text))
end

function M.setup(config)
  vim.validate({ config = { config, "table" } })
  require("cmdhndlr.core.custom").set(config)
end

function M.executed_runners()
  local items = {}
  for _, state in ipairs(State.all()) do
    table.insert(items, {
      full_name = state.full_name,
      bufnr = state.bufnr,
      is_running = state.job:is_running(),
    })
  end
  return items
end

function M.execute(full_name, raw_opts)
  raw_opts = raw_opts or {}

  local index = full_name:find("/")
  if index then
    raw_opts.name = full_name:sub(index + 1)
  end

  if vim.startswith(full_name, "normal_runner/") then
    return M.run(raw_opts)
  end
  if vim.startswith(full_name, "test_runner/") then
    return M.test(raw_opts)
  end
  if vim.startswith(full_name, "build_runner/") then
    return M.build(raw_opts)
  end
  if vim.startswith(full_name, "format_runner/") then
    return M.format(raw_opts)
  end

  require("cmdhndlr.vendor.misclib.message").error("unexpected runner name: " .. full_name)
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

function M.get(full_name)
  return require("cmdhndlr.core.runner.handler").from_full_name(full_name, {
    working_dir = function() end,
    working_dir_marker = function() end,
  })
end

function M.runners()
  return require("cmdhndlr.core.runner.handler").all()
end

return M
