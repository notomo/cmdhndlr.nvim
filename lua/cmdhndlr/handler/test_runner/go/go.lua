local M = {}

function M.run_file(self, _)
  return self.job_factory:create({"go", "test", "-v"})
end

local lang = "go"

function M._find_test(_, root, position)
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
  local tests = {}
  for _, match, metadata in root:iter_matches(query, 0, position[1]) do
    for id, node in match:iter() do
      if metadata[id] and metadata[id] == "ignore" then
        goto continue
      end

      table.insert(tests, {name = node:to_text(), id = node:id(), row = node:row()})
      ::continue::
    end
  end
  return tests[#tests]
end

-- TODO: refactor nested query
function M._find_test_run(self, test, root, position)
  local query = vim.treesitter.parse_query(lang, [[
(call_expression
    function: (selector_expression
        operand: (identifier) @t (eq? @t "t") (#set! @t "ignore")
        field: (field_identifier) @run (eq? @run "Run") (#set! @run "ignore")
    )
    arguments: (argument_list
        [(interpreted_string_literal) (raw_string_literal)] @test_run_name
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
                        [(interpreted_string_literal) (raw_string_literal)] @nested_test_run_name
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
        [(interpreted_string_literal) (raw_string_literal)] @test_run_name
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

  local test_runs = self.NodeJointer.new()
  for _, match, metadata in root:iter_matches(query, test.row, position[1]) do
    local test_run = {}
    for id, node in match:iter() do
      if metadata[id] and metadata[id] == "ignore" then
        goto continue
      end

      table.insert(test_run, {name = node:to_text(), id = node:id()})
      ::continue::
    end
    test_runs:add(test_run)
  end

  local test_run = test_runs:last()
  if not test_run then
    return nil
  end

  local unwrapper = self.StringUnwrapper.for_go()
  local names = vim.tbl_map(function(case)
    return unwrapper:unwrap(case.name)
  end, test_run)
  return {names = names}
end

function M.run_position_scope(self, path, position)
  local root, err = self.parser:parse(lang)
  if err ~= nil then
    return nil, err
  end

  local test = self:_find_test(root, position)
  if not test then
    return self:run_file(path)
  end

  local test_run = self:_find_test_run(test, root, position)
  local pattern
  if test_run then
    pattern = table.concat({test.name, unpack(test_run.names)}, "/")
  else
    pattern = test.name
  end

  return self.job_factory:create({"go", "test", "-v", "--run=" .. pattern})
end

return M
