local M = {}

local plugin_name = vim.split((...):gsub("%.", "/"), "/", true)[1]
local prefix = ("[%s] "):format(plugin_name)

function M.error(err)
  error(M.wrap(err))
end

function M.warn(msg)
  vim.api.nvim_echo({ { M.wrap(msg), "WarningMsg" } }, true, {})
end

function M.wrap(msg)
  if type(msg) == "string" then
    return prefix .. msg
  end
  return prefix .. vim.inspect(msg)
end

function M.echo(msg, hl_group)
  local chunk = { M.wrap(msg) }
  if hl_group then
    table.insert(chunk, hl_group)
  end
  vim.api.nvim_echo({ chunk }, true, {})
end

return M
