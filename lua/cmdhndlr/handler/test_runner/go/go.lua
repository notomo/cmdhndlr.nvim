local M = {}

function M.run_file(self, _)
  return self.job_factory:create({"go", "test", "-v"})
end

local lang = "go"

function M._find_test(_, bufnr, position)
  local query = vim.treesitter.parse_query(lang, [[
(function_declaration
    name: (identifier) @name (match? @name "^Test")
    parameters: (parameter_list
        (parameter_declaration
            name: (identifier) @t (eq? @t "t") (#set! @t "ignore")
            type: (pointer_type
                (qualified_type
                    package: (package_identifier) @testing (match? @testing "testing") (#set! @testing "ignore")
                    name: (type_identifier)
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
    for id, node in pairs(match) do
      if metadata[id] and metadata[id] == "ignore" then
        goto continue
      end

      local row_s, col_s, row_e, col_e = node:range()
      local name = vim.api.nvim_buf_get_lines(bufnr, row_s, row_e + 1, false)[1]:sub(col_s + 1, col_e)
      table.insert(tests, {name = name, id = node:id(), row = row_s})
      ::continue::
    end
  end
  return tests[#tests]
end

-- TODO: refactor nested query
function M._find_test_run(_, test, bufnr, position)
  local query = vim.treesitter.parse_query(lang, [[
(call_expression
    function: (selector_expression
        operand: (identifier) @t (eq? @t "t") (#set! @t "ignore")
        field: (field_identifier) @run (eq? @run "Run") (#set! @run "ignore")
    )
    arguments: (argument_list
        (interpreted_string_literal) @test_run_name
        (func_literal
            parameters: (parameter_list
                (parameter_declaration
                    name: (identifier) @t2 (eq? @t2 "t") (#set! @t2 "ignore")
                    type: (pointer_type
                        (qualified_type
                            package: (package_identifier) @testing (match? @testing "testing") (#set! @testing "ignore")
                        )
                    )
                )
            )
            body: (block
                (call_expression
                    function: (selector_expression
                        operand: (identifier) @t (eq? @t "t") (#set! @t "ignore")
                        field: (field_identifier) @run (eq? @run "Run") (#set! @run "ignore")
                    )
                    arguments: (argument_list
                        (interpreted_string_literal) @nested_test_run_name
                        (func_literal
                            parameters: (parameter_list
                                (parameter_declaration
                                    name: (identifier) @t2 (eq? @t2 "t") (#set! @t2 "ignore")
                                    type: (pointer_type
                                        (qualified_type
                                            package: (package_identifier) @testing (match? @testing "testing") (#set! @testing "ignore")
                                        )
                                    )
                                )
                            )
                        )
                    )
                )
            )
        )
    )
)
(call_expression
    function: (selector_expression
        operand: (identifier) @t (eq? @t "t") (#set! @t "ignore")
        field: (field_identifier) @run (eq? @run "Run") (#set! @run "ignore")
    )
    arguments: (argument_list
        (interpreted_string_literal) @test_run_name
        (func_literal
            parameters: (parameter_list
                (parameter_declaration
                    name: (identifier) @t2 (eq? @t2 "t") (#set! @t2 "ignore")
                    type: (pointer_type
                        (qualified_type
                            package: (package_identifier) @testing (match? @testing "testing") (#set! @testing "ignore")
                        )
                    )
                )
            )
        )
    )
)
]])
  local parser = vim.treesitter.get_parser(bufnr, lang)
  local trees, _ = parser:parse()

  local test_runs = {}
  local it = query:iter_matches(trees[1]:root(), bufnr, test.row, position[1])
  for _, match, metadata in it do
    local test_run = {}
    for id, node in pairs(match) do
      if metadata[id] and metadata[id] == "ignore" then
        goto continue
      end

      local row_s, col_s, row_e, col_e = node:range()
      local name = vim.api.nvim_buf_get_lines(bufnr, row_s, row_e + 1, false)[1]:sub(col_s + 1, col_e)
      table.insert(test_run, {name = name, id = node:id()})
      ::continue::
    end

    local current_first = test_run[1]
    local before_test_run = test_runs[#test_runs] or {}
    local before_last = before_test_run[#before_test_run]
    if current_first and before_last and current_first.id == before_last.id then
      table.remove(test_run, 1)
      vim.list_extend(test_runs[#test_runs], test_run)
    else
      table.insert(test_runs, test_run)
    end
  end

  local test_run = test_runs[#test_runs]
  if not test_run then
    return nil
  end

  local names = vim.tbl_map(function(case)
    return M._unwrap_string(case.name)
  end, test_run)
  return {names = names}
end

function M.run_position_scope(self, bufnr, path, position)
  if not vim.treesitter.language.require_language("go", nil, true) then
    return nil, "not found tree-sitter parser for " .. lang
  end

  local test = self:_find_test(bufnr, position)
  if not test then
    return self:run_file(path)
  end

  local test_run = self:_find_test_run(test, bufnr, position)
  local pattern
  if test_run then
    pattern = table.concat({test.name, unpack(test_run.names)}, "/")
  else
    pattern = test.name
  end

  return self.job_factory:create({"go", "test", "-v", "--run=" .. pattern})
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
  if vim.startswith(str, "`") then
    local res = str:gsub("^`", ""):gsub("`$", "")
    return res
  end
  error("gave up _unwrap_string(): " .. str)
end

return M
