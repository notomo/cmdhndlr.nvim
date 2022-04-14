local Layouts = {}

function Layouts.no() end

function Layouts.horizontal()
  return function()
    vim.cmd("botright split")
  end
end

function Layouts.tab()
  vim.cmd("tabedit")
end

local Layout = {}
Layout.__index = Layout

function Layout.new(opts)
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

  local tbl = { _f = f }
  return setmetatable(tbl, Layout)
end

function Layout.open(self, bufnr)
  vim.validate({ bufnr = { bufnr, "number" } })
  self._f()
  vim.api.nvim_win_set_buf(0, bufnr)
  return vim.api.nvim_get_current_win()
end

return Layout
