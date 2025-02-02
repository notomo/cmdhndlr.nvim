local M = {}

M.config = {
  normal_runner = {
    default = {
      lua = "vim/lua",
      go = "go/go",
      sh = "shell/bash",
      bash = "shell/bash",
      zsh = "shell/zsh",
      vim = "vim/source",
      python = "python/python",
      make = "make/make",
      javascript = "javascript/node",
      typescript = "typescript/ts_node",
      typescriptreact = "typescript/deno",
      ["typescript.tsx"] = "typescript/deno",
      dart = "dart/dart",
      rust = "rust/cargo",
      zig = "zig/zig",
      autohotkey = "autohotkey/autohotkey",
      sql = "sql/sqlite3",
      zip = "zip/unzip",
      gz = "gz/gunzip",
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
      typescript = "javascript/jest",
      typescriptreact = "javascript/jest",
      zig = "zig/zig",
    },
  },
  build_runner = {
    default = {
      go = "go/go",
      javascript = "javascript/npm",
      typescript = "javascript/npm",
      typescriptreact = "javascript/npm",
      c = "c/clang",
      dockerfile = "dockerfile/docker",
    },
  },
  format_runner = {
    default = {
      json = "json/fixjson",
      jsonc = "json/fixjson",
      typescript = "javascript/prettier",
      typescriptreact = "javascript/prettier",
      ["typescript.tsx"] = "javascript/prettier",
      astro = "javascript/prettier",
      terraform = "terraform/terraform",
      hcl = "terraform/terraform",
      python = "python/black",
      javascript = "javascript/prettier",
      css = "javascript/prettier",
      html = "javascript/prettier",
      graphql = "javascript/prettier",
      yaml = "yaml/yamlfmt",
      rust = "rust/rustfmt",
      go = "go/goimports",
      c = "c/uncrustify",
      cpp = "c/uncrustify",
      lua = "lua/stylua",
      zig = "zig/zig",
    },
  },
  log_file_path = vim.fs.joinpath(tostring(vim.fn.stdpath("log")), "cmdhndlr.log"),
  opts = {},
}

function M.set(config)
  M.config = vim.tbl_deep_extend("force", M.config, config)
end

return M
