local hl_groups = require("cmdhndlr.view.highlight_group")

local M = {}

local cmd_to_msg = function(cmd)
  if type(cmd) == "string" then
    return cmd
  end

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

local echo_truncated = function(title, msg, hl_group)
  local prefix = "[cmdhndlr] " .. title
  local max_width = math.floor(vim.o.columns * 0.90) -- suppress Press ENTER message
  if max_width < vim.fn.strdisplaywidth(prefix .. msg) then
    msg = vim.fn.strpart(msg, 0, max_width - 3 - #prefix) .. "..."
  end

  vim.api.nvim_echo({ { prefix, hl_group }, { msg } }, true, {})
end

function M.echo_success()
  return function(info)
    local msg = (" %d ms: %s"):format(info.elapsed_ms, cmd_to_msg(info.cmd))
    echo_truncated("SUCCESS:", msg, hl_groups.CmdhndlrSuccess)
  end
end

function M.echo_failure()
  return function(info)
    local msg = (" %d ms: %s"):format(info.elapsed_ms, cmd_to_msg(info.cmd))
    echo_truncated("FAILURE:", msg, hl_groups.CmdhndlrFailure)
  end
end

function M.echo_cmd()
  return function(ctx)
    local msg = (" %s"):format(cmd_to_msg(ctx.cmd))
    echo_truncated("STARTING:", msg)
  end
end

return M
