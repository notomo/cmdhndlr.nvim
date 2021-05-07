local Command = require("cmdhndlr.command").Command

local M = {}

function M.run(opts)
  return Command.new("run", opts)
end

function M.test(opts)
  return Command.new("test", opts)
end

function M.setup(config)
  return Command.new("setup", config)
end

return M
