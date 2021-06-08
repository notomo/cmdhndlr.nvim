local M = {}

M.cmd = "busted"

function M.run_file(self, path)
  return self.job_factory:create({self.cmd, path})
end

function M.run_position_scope(self, _, path, position)
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

  local tests = self.NodeJointer.new()
  for _, match, metadata in root:iter_matches(query, 0, position[1]) do
    local test = {}
    local is_it = false
    for id, node in match:iter() do
      if query.captures[id] == "describe_or_it" then
        is_it = node:to_text() == "it"
      end

      if metadata[id] and metadata[id] == "ignore" then
        goto continue
      end

      table.insert(test, {name = node:to_text(), id = node:id(), is_it = is_it})
      ::continue::
    end
    tests:add(test)
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
