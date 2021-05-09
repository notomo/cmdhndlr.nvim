local M = {}

M.config = {
  runner = {
    default = {
      lua = "vim/lua",
      go = "go/go",
      sh = "shell/bash",
      vim = "vim/source",
      python = "python/python",
      make = "make/make",
      javascript = "javascript/node",
      dart = "dart/dart",
    },
  },
  test_runner = {default = {lua = "lua/busted", go = "go/go", python = "python/pytest"}},
}

function M.set(config)
  M.config = vim.tbl_deep_extend("force", M.config, config)
end

return M
