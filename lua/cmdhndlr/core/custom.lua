local M = {}

M.config = {
  runner = {default = {lua = "vim/lua", go = "go/go", sh = "shell/bash"}},
  test_runner = {default = {lua = "lua/busted"}},
}

function M.set(config)
  M.config = vim.tbl_deep_extend("force", M.config, config)
end

return M
