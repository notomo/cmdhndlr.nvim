local Layouts = {}

function Layouts.no(bufnr)
  vim.api.nvim_win_set_buf(0, bufnr)
end

function Layouts.horizontal(bufnr)
  vim.cmd.split({ mods = { split = "botright" } })
  vim.api.nvim_win_set_buf(0, bufnr)
end

function Layouts.tab(bufnr)
  vim.cmd.tabedit()
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.api.nvim_win_set_buf(0, bufnr)
end

function Layouts.tab_drop(bufnr)
  local window_id = vim.fn.win_findbuf(bufnr)[1]
  if not window_id then
    Layouts.tab(bufnr)
    return
  end

  vim.api.nvim_set_current_win(window_id)
end

local Layout = {}

function Layout.open(bufnr, opts)
  vim.validate({ bufnr = { bufnr, "number" } })
  opts = opts or {}

  local typ = opts.type
  local f = Layouts[typ]
  if not f then
    error("unexpected layout type: " .. tostring(typ))
  end

  f(bufnr)

  return vim.api.nvim_get_current_win()
end

return Layout
