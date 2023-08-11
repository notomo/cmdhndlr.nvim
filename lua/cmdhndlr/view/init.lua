local Layout = require("cmdhndlr.view.layout")

local M = {}

function M.open(bufnr, working_dir, layout_opts)
  vim.validate({
    bufnr = { bufnr, "number" },
    working_dir = { working_dir, "table" },
    layout_opts = { layout_opts, "table", true },
  })

  if not layout_opts then
    return
  end

  vim.schedule(function()
    vim.cmd.startinsert({ bang = true })
  end)

  vim.bo[bufnr].filetype = "cmdhndlr"
  Layout.new(layout_opts):open(bufnr)
  working_dir:set_current()
end

return M
