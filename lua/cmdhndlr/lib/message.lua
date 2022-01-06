local M = {}

local plugin_name = vim.split((...):gsub("%.", "/"), "/", true)[1]
local prefix = ("[%s] "):format(plugin_name)

function M.error(err)
  error(prefix .. err)
end

function M.warn(msg)
  vim.validate({ msg = { msg, "string" } })
  vim.api.nvim_echo({ { prefix .. msg, "WarningMsg" } }, true, {})
end

function M.echo(msg, hl_group)
  vim.validate({ msg = { msg, "string" }, hl_group = { hl_group, "string", true } })
  local chunk = { prefix .. msg }
  if hl_group then
    table.insert(chunk, hl_group)
  end
  vim.api.nvim_echo({ chunk }, true, {})
end

return M
