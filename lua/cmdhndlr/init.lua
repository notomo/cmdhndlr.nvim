local Command = require("cmdhndlr.command").Command

local M = {}

function M.run(opts)
  return Command.new("run", opts)
end

function M.test(opts)
  return Command.new("test", opts)
end

return M
