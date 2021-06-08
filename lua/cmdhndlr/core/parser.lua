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

local Match = {}
Match.__index = Match

function Match.new(bufnr, raw_match)
  local tbl = {_bufnr = bufnr, _match = raw_match}
  return setmetatable(tbl, Match)
end

function Match.iter(self)
  local id = nil
  return function()
    local node
    id, node = next(self._match, id)
    if not id then
      return nil
    end
    return id, M.Node.new(self._bufnr, node)
  end
end

local Node = {}
M.Node = Node

function Node.new(bufnr, raw_node)
  local tbl = {_node = raw_node, _bufnr = bufnr}
  return setmetatable(tbl, Node)
end

function Node.__index(self, k)
  return rawget(Node, k) or self._node[k]
end

function Node.id(self)
  return self._node:id()
end

function Node.row(self)
  local row_s = self._node:range()
  return row_s
end

function Node.to_text(self)
  local row_s, col_s, row_e, col_e = self._node:range()
  return vim.api.nvim_buf_get_lines(self._bufnr, row_s, row_e + 1, false)[1]:sub(col_s + 1, col_e)
end

function Node.iter_matches(self, query, s, e)
  local iter = query:iter_matches(self._node, self._bufnr, s, e)
  return function()
    local id, match, metadata = iter()
    if not id then
      return nil
    end
    return id, Match.new(self._bufnr, match), metadata
  end
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
  return Node.new(self._bufnr, trees[1]:root())
end

return M
