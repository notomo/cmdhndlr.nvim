local Command = require("cmdhndlr.command").Command

local M = {}

function M.run(opts)
  return Command.new("run", opts)
end

function M.test(opts)
  return Command.new("test", opts)
end

function M.build(opts)
  return Command.new("build", opts)
end

function M.retry()
  return Command.new("retry")
end

function M.setup(config)
  return Command.new("setup", config)
end

return M
