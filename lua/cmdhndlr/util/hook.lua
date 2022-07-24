local messagelib = require("cmdhndlr.vendor.misclib.message")

local M = {}

vim.api.nvim_set_hl(0, "CmdhndlrSuccess", { link = "Search" })
vim.api.nvim_set_hl(0, "CmdhndlrFailure", { link = "Todo" })

function M.echo_success()
  return function(info)
    local msg = ("SUCCESS: %d ms"):format(info.elapsed_ms)
    messagelib.info(msg, "CmdhndlrSuccess")
  end
end

function M.echo_failure()
  return function(info)
    local msg = ("FAILURE: %d ms"):format(info.elapsed_ms)
    messagelib.info(msg, "CmdhndlrFailure")
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
    messagelib.info("STARTING: " .. msg)
  end
end

return M
