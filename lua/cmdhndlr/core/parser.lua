local M = {}

local Parser = {}
Parser.__index = Parser
M.Parser = Parser

function Parser.new(bufnr)
  vim.validate({bufnr = {bufnr, "number"}})
  local tbl = {_bufnr = bufnr}
  return setmetatable(tbl, Parser)
end

function Parser.parse(self, lang)
  vim.validate({lang = {lang, "string"}})

  if not vim.treesitter.language.require_language(lang, nil, true) then
    return nil, "not found tree-sitter parser for " .. lang
  end

  local parser = vim.treesitter.get_parser(self._bufnr, lang)
  local trees, _ = parser:parse()
  return trees[1]:root()
end

return M
