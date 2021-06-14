local M = {}

M.cmd = "busted"

function M.run_file(self, path)
  return self.job_factory:create({self.cmd, path})
end

function M.run_position_scope(self, path, position)
  local lang = "lua"

  local root, err = self.parser:parse(lang)
  if err ~= nil then
    return nil, err
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
(function_call
    (identifier) @describe (#eq? @describe "describe") (#set! @describe "ignore")
    (arguments
        (string) @describe_name
    )
)
]])

  local tests = self.TableJoiner.new()
  local end_row = position[1]
  for _, match in root:iter_matches(query, 0, end_row) do
    local test = {}
    local is_it = false
    local f = function(node)
      is_it = node.capture_name == "describe_or_it" and node:text() == "it"
    end
    for _, node in match:iter(f) do
      table.insert(test, {name = node:text(), id = node:id(), is_it = is_it, row = node:row()})
    end
    -- HACK ?
    if test[#test] and test[#test].row < end_row then
      tests:add(test)
    end
  end

  local test = tests:last()
  if not test then
    return self:run_file(path)
  end

  local unwrapper = self.StringUnwrapper.for_lua()
  local pattern = table.concat(vim.tbl_map(function(case)
    return unwrapper:unwrap(case.name)
  end, test), " ")
  if test[#test].is_it then
    pattern = pattern .. "$"
  end
  pattern = pattern:gsub("%(", "%%("):gsub("%)", "%%)"):gsub("%-", "%%-")

  return self.job_factory:create({self.cmd, "--filter", pattern, path})
end

return M
