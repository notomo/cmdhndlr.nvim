local setup_highlight_groups = function()
  local highlightlib = require("cmdhndlr.vendor.misclib.highlight")
  return {
    CmdhndlrSuccess = highlightlib.link("CmdhndlrSuccess", "Search"),
    CmdhndlrFailure = highlightlib.link("CmdhndlrFailure", "Todo"),
  }
end

local group = vim.api.nvim_create_augroup("cmdhndlr_color", {})
vim.api.nvim_create_autocmd({ "ColorScheme" }, {
  group = group,
  pattern = { "*" },
  callback = setup_highlight_groups,
})

return setup_highlight_groups()
