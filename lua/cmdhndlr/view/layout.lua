local Layouts = {}

function Layouts.no() end

function Layouts.horizontal()
  return function()
    vim.cmd.split({ mods = { split = "botright" } })
  end
end

function Layouts.tab()
  vim.cmd.tabedit()
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
end

local Layout = {}

function Layout.open(bufnr, opts)
  vim.validate({ bufnr = { bufnr, "number" } })

  opts = opts or {}
  local typ = opts.type

  local f
  if typ == "horizontal" then
    f = Layouts.horizontal()
  elseif typ == "tab" then
    f = Layouts.tab
  elseif typ == "no" then
    f = Layouts.no
  else
    error("unexpected layout type: " .. tostring(typ))
  end

  f()
  vim.api.nvim_win_set_buf(0, bufnr)
  return vim.api.nvim_get_current_win()
end

return Layout
