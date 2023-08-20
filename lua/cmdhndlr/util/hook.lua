local messagelib = require("cmdhndlr.vendor.misclib.message")
local hl_groups = require("cmdhndlr.view.highlight_group")

local M = {}

function M.echo_success()
  return function(info)
    local msg = ("SUCCESS: %d ms"):format(info.elapsed_ms)
    messagelib.info(msg, hl_groups.CmdhndlrSuccess)
  end
end

function M.echo_failure()
  return function(info)
    local msg = ("FAILURE: %d ms"):format(info.elapsed_ms)
    messagelib.info(msg, hl_groups.CmdhndlrFailure)
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

    msg = "[cmdhndlr] STARTING: " .. msg
    local max_width = math.floor(vim.o.columns * 0.90) -- suppress Press ENTER message
    if max_width < vim.fn.strdisplaywidth(msg) then
      msg = vim.fn.strpart(msg, 0, max_width - 3) .. "..."
    end

    vim.api.nvim_echo({ { msg } }, true, {})
  end
end

return M
