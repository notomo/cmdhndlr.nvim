local Runner = require("cmdhndlr.core.runner").Runner
local TestRunner = require("cmdhndlr.core.test_runner").TestRunner
local Hooks = require("cmdhndlr.core.hook").Hooks
local custom = require("cmdhndlr.core.custom")
local View = require("cmdhndlr.view").View
local messagelib = require("cmdhndlr.lib.message")
local modelib = require("cmdhndlr.lib.mode")

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

  local hooks = Hooks.new()

  local bufnr = vim.api.nvim_get_current_buf()
  local runner, err = Runner:dispatch(bufnr, opts.name, hooks, opts.working_dir, opts.runner_opts)
  if err ~= nil then
    return nil, err
  end

  local range = modelib.visual_range()
  local view = View.open(runner.working_dir)
  local result, exec_err = runner:execute(range)
  if exec_err ~= nil then
    return nil, exec_err
  end
  view:set_lines(result.output)
  view:cursor_to_bottom()

  result:hook()

  return result, nil
end

function Command.test(opts)
  vim.validate({opts = {opts, "table", true}})
  opts = opts or {}

  opts.hooks = opts.hooks or {}
  opts.hooks.success = opts.hooks.success or function()
    messagelib.echo("SUCCESS", "Search")
  end
  opts.hooks.failure = opts.hooks.failure or function()
    messagelib.echo("FAILURE", "TODO")
  end
  local hooks = Hooks.new(opts.hooks.success, opts.hooks.failure)

  local bufnr = vim.api.nvim_get_current_buf()
  local test_runner, err = TestRunner:dispatch(bufnr, opts.name, hooks, opts.working_dir, opts.runner_opts)
  if err ~= nil then
    return nil, err
  end

  local view = View.open(test_runner.working_dir)
  local result, exec_err = test_runner:execute()
  if exec_err ~= nil then
    return nil, exec_err
  end
  view:set_lines(result.output)
  view:cursor_to_bottom()

  result:hook()

  return result, nil
end

function Command.setup(config)
  vim.validate({config = {config, "table"}})
  custom.set(config)
end

return M
