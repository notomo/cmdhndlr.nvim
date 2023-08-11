local M = {}

M.config = {
  normal_runner = {
    default = {
      lua = "vim/lua",
      go = "go/go",
      sh = "shell/bash",
      zsh = "shell/zsh",
      vim = "vim/source",
      python = "python/python",
      make = "make/make",
      javascript = "javascript/node",
      typescript = "typescript/deno",
      ["typescript.tsx"] = "typescript/deno",
      dart = "dart/dart",
      rust = "rust/cargo",
      zig = "zig/zig",
      autohotkey = "autohotkey/autohotkey",
      sql = "sql/sqlite3",
      zip = "zip/unzip",
      tar = "tar/tar_unarchive",
      ocaml = "ocaml/ocaml",
    },
  },
  test_runner = {
    default = {
      lua = "lua/vusted",
      go = "go/go",
      python = "python/pytest",
      rust = "rust/cargo",
      javascript = "javascript/jest",
      typescript = "typescript/deno",
      zig = "zig/zig",
    },
  },
  build_runner = {
    default = {
      go = "go/go",
      javascript = "javascript/npm",
      typescript = "javascript/npm",
      c = "c/clang",
      dockerfile = "dockerfile/docker",
    },
  },
  format_runner = {
    default = {
      json = "json/fixjson",
    },
  },
  log_file_path = vim.fn.stdpath("log") .. "/cmdhndlr.log",
  env = {},
}

function M.set(config)
  M.config = vim.tbl_deep_extend("force", M.config, config)
end

return M
