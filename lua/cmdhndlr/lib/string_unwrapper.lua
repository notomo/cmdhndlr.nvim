local M = {}

local StringUnwrapper = {}
StringUnwrapper.__index = StringUnwrapper
M.StringUnwrapper = StringUnwrapper

function StringUnwrapper.new(...)
  local patterns = vim.tbl_map(function(pair)
    local head = "^" .. pair[1]
    local tail = (pair[2] or pair[1]) .. "$"
    return { head = head, tail = tail }
  end, { ... })

  local tbl = { _patterns = patterns }
  return setmetatable(tbl, StringUnwrapper)
end

function StringUnwrapper.for_lua()
  return StringUnwrapper.new({ "'" }, { '"' }, { "%[=*%[", "%]=*%]" })
end

function StringUnwrapper.for_go()
  return StringUnwrapper.new({ "'" }, { '"' }, { "`" })
end

function StringUnwrapper.unwrap(self, str)
  for _, pattern in ipairs(self._patterns) do
    local remove_head, count = str:gsub(pattern.head, "")
    if count > 0 then
      local result = remove_head:gsub(pattern.tail, "")
      return result
    end
  end
  error("gave up unwrap string: " .. str)
end

return M
