local Command = require("cmdhndlr.command").Command

local M = {}

function M.run(opts)
  return Command.new("run", opts)
end

return M
