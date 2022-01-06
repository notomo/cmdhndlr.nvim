local M = {}

local Match = {}
Match.__index = Match

function Match.new(bufnr, raw_match, metadata, captures)
  local tbl = { _bufnr = bufnr, _match = raw_match, _metadata = metadata or {}, _captures = captures }
  return setmetatable(tbl, Match)
end

function Match.iter(self, f)
  local id = nil
  f = f or function() end
  return function()
    local node
    local ok = false
    repeat
      id, node = next(self._match, id)
      if not id then
        return nil
      end
      node = M.Node.new(self._bufnr, node, self._captures[id])
      f(node)
      ok = self._metadata[id] ~= "ignore"
    until ok
    return id, node
  end
end

function Match.map(self, f)
  vim.validate({ f = { f, "function" } })
  local tbl = {}
  for _, node in self:iter() do
    table.insert(tbl, f(node))
  end
  return tbl
end

local Node = {}
M.Node = Node

function Node.new(bufnr, raw_node, capture_name)
  local tbl = { _node = raw_node, _bufnr = bufnr, capture_name = capture_name }
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

function Node.text(self)
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
    return id, Match.new(self._bufnr, match, metadata, query.captures), metadata
  end
end

local Parser = {}
Parser.__index = Parser
M.Parser = Parser

function Parser.new(bufnr)
  vim.validate({ bufnr = { bufnr, "number" } })
  local tbl = { _bufnr = bufnr }
  return setmetatable(tbl, Parser)
end

function Parser.parse(self, lang)
  vim.validate({ lang = { lang, "string" } })

  if not vim.treesitter.language.require_language(lang, nil, true) then
    return nil, { msg = "not found tree-sitter parser for " .. lang }
  end

  local parser = vim.treesitter.get_parser(self._bufnr, lang)
  local trees, _ = parser:parse()
  return Node.new(self._bufnr, trees[1]:root())
end

return M
