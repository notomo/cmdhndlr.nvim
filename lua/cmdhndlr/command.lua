local View = require("cmdhndlr.view").View
local Runner = require("cmdhndlr.core.runner").Runner
local messagelib = require("cmdhndlr.lib.message")

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
  local runner, err = Runner.dispatch(bufnr, opts.name, opts.runner_opts)
  if err ~= nil then
    return nil, err
  end

  View.open()

  -- TODO: show sync command output
  return runner:execute()
end

return M
