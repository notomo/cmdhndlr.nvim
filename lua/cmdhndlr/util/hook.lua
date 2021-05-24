local messagelib = require("cmdhndlr.lib.message")

local M = {}

vim.cmd("highlight default link CmdhndlrSuccess Search")
vim.cmd("highlight default link CmdhndlrFailure Todo")

function M.echo_success()
  return function()
    messagelib.echo("SUCCESS", "CmdhndlrSuccess")
  end
end

function M.echo_failure()
  return function()
    messagelib.echo("FAILURE", "CmdhndlrFailure")
  end
end

return M
