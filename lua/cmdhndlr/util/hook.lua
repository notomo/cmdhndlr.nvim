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

local tbl_to_msg = function(cmd)
  local parts = {}
  for _, c in ipairs(cmd) do
    if c:find("%s") then
      table.insert(parts, "'" .. c .. "'")
    else
      table.insert(parts, c)
    end
  end
  return table.concat(parts, " ")
end

function M.echo_cmd()
  return function(cmd)
    local msg
    if type(cmd) == "table" then
      msg = tbl_to_msg(cmd)
    else
      msg = cmd
    end
    messagelib.echo("STARTING: " .. msg)
  end
end

return M
