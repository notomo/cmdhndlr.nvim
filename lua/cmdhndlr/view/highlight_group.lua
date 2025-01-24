local setup_highlight_groups = function()
  local highlightlib = require("cmdhndlr.vendor.misclib.highlight")
  return {
    CmdhndlrSuccess = highlightlib.link("CmdhndlrSuccess", "Search"),
    CmdhndlrFailure = highlightlib.link("CmdhndlrFailure", "Todo"),
  }
end

local group = vim.api.nvim_create_augroup("cmdhndlr.highlight_group", {})
vim.api.nvim_create_autocmd({ "ColorScheme" }, {
  group = group,
  pattern = { "*" },
  callback = function()
    setup_highlight_groups()
  end,
})

return setup_highlight_groups()
