local M = {}

M.cmd = "busted"

function M.run_file(self, path)
  return self.job_factory:create({self.cmd, path})
end

function M.run_position_scope(self, bufnr, path, position)
  local lang = "lua"
  if not vim.treesitter.language.require_language("lua", nil, true) then
    return nil, "not found tree-sitter parser for " .. lang
  end

  local query = vim.treesitter.parse_query(lang, [[
(function_call
    (identifier) @describe (#eq? @describe "describe") (#set! @describe "ignore")
    (arguments
        (string) @describe_name
        (function_definition
            (function_call
                (identifier) @describe_or_it (#any-of? @describe_or_it "describe" "it") (#set! @describe_or_it "ignore")
                (arguments
                  (string) @describe_or_it_name
                )
            )
        )
    )
)
]])
  local parser = vim.treesitter.get_parser(bufnr, lang)
  local trees, _ = parser:parse()

  local it = query:iter_matches(trees[1]:root(), bufnr, 0, position[1])
  local tests = {}
  for _, match, metadata in it do
    local test = {}
    local is_it = false
    for id, node in pairs(match) do
      if query.captures[id] == "describe_or_it" then
        local row_s, col_s, row_e, col_e = node:range()
        local name = vim.api.nvim_buf_get_lines(bufnr, row_s, row_e + 1, false)[1]:sub(col_s + 1, col_e)
        is_it = name == "it"
      end

      if metadata[id] and metadata[id] == "ignore" then
        goto continue
      end

      local row_s, col_s, row_e, col_e = node:range()
      local name = vim.api.nvim_buf_get_lines(bufnr, row_s, row_e + 1, false)[1]:sub(col_s + 1, col_e)
      table.insert(test, {name = name, id = node:id(), is_it = is_it})
      ::continue::
    end

    local current_first = test[1]
    local before_test = tests[#tests] or {}
    local before_last = before_test[#before_test]
    if current_first and before_last and current_first.id == before_last.id then
      table.remove(test, 1)
      vim.list_extend(tests[#tests], test)
    else
      table.insert(tests, test)
    end
  end

  local test = tests[#tests]
  if not test then
    return self:run_file(path)
  end

  local pattern = table.concat(vim.tbl_map(function(case)
    return M._unwrap_string(case.name)
  end, test), " ")
  if test[#test].is_it then
    pattern = pattern .. "$"
  end
  pattern = pattern:gsub("%(", "%%("):gsub("%)", "%%)"):gsub("%-", "%%-")

  return self.job_factory:create({self.cmd, "--filter", pattern, path})
end

function M._unwrap_string(str)
  if vim.startswith(str, "'") then
    local res = str:gsub("^'", ""):gsub("'$", "")
    return res
  end
  if vim.startswith(str, "\"") then
    local res = str:gsub("^\"", ""):gsub("\"$", "")
    return res
  end
  if vim.startswith(str, "[") then
    local res = str:gsub("^%[=*%[", ""):gsub("%]=*%]$", "")
    return res
  end
  error("gave up _unwrap_string(): " .. str)
end

return M
