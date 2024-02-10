local Layout = require("cmdhndlr.view.layout")

local M = {}

function M.open(bufnr, working_dir, layout_opts)
  vim.validate({
    bufnr = { bufnr, "number" },
    working_dir = { working_dir, "table" },
    layout_opts = { layout_opts, "table", true },
  })

  if not layout_opts then
    return vim.api.nvim_get_current_win()
  end

  local window_id = Layout.open(bufnr, layout_opts)
  vim.schedule(function()
    if vim.api.nvim_get_current_win() ~= window_id then
      return
    end
    vim.cmd.startinsert({ bang = true })
  end)

  working_dir:set_current()
  vim.bo[bufnr].filetype = "cmdhndlr"

  return window_id
end

return M
