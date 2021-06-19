local messagelib = require("cmdhndlr.lib.message")

local M = {}

vim.cmd("highlight default link CmdhndlrSuccess Search")
vim.cmd("highlight default link CmdhndlrFailure Todo")

function M.echo_success()
  return function(info)
    local msg = ("SUCCESS: %d ms"):format(info.elapsed_ms)
    messagelib.echo(msg, "CmdhndlrSuccess")
  end
end

function M.echo_failure()
  return function(info)
    local msg = ("FAILURE: %d ms"):format(info.elapsed_ms)
    messagelib.echo(msg, "CmdhndlrFailure")
  end
end

return M
