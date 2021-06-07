local M = {}

local NodeJointer = {}
M.NodeJointer = NodeJointer

function NodeJointer.new()
  local tbl = {_holders = {}}
  return setmetatable(tbl, NodeJointer)
end

function NodeJointer.add(self, node_holder)
  vim.validate({node_holder = {node_holder, "table"}})

  local current_first = node_holder[1]

  local before = self._holders[#self._holders] or {}
  local last = before[#before]

  if current_first and last and current_first.id == last.id then
    table.remove(node_holder, 1)
    vim.list_extend(self._holders[#self._holders], node_holder)
    return
  end
  table.insert(self._holders, node_holder)
end

function NodeJointer.last(self)
  return self._holders[#self._holders]
end

function NodeJointer.__index(self, k)
  if type(k) == "number" then
    return self._holders[k]
  end
  return NodeJointer[k]
end

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
