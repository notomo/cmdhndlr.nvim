local M = {}

local StringUnwrapper = {}
StringUnwrapper.__index = StringUnwrapper
M.StringUnwrapper = StringUnwrapper

function StringUnwrapper.new(...)
  local patterns = vim.tbl_map(function(e)
    local adjust = e.adjust or function(s)
      return s
    end
    return { head = e.head, tail = e.tail, adjust = adjust }
  end, { ... })

  local tbl = { _patterns = patterns }
  return setmetatable(tbl, StringUnwrapper)
end

function StringUnwrapper.for_lua()
  local unescape = function(s)
    s = s:gsub([[\\]], [[\]])
    return s
  end
  return StringUnwrapper.new(
    { head = "'", tail = "'", adjust = unescape },
    { head = '"', tail = '"', adjust = unescape },
    { head = "%[=*%[", tail = "%]=*%]" }
  )
end

function StringUnwrapper.for_go()
  local escape = function(s)
    s = s:gsub([[\]], [[\\]])
    return s
  end
  return StringUnwrapper.new({ head = '"', tail = '"' }, { head = "`", tail = "`", adjust = escape })
end

function StringUnwrapper.unwrap(self, str)
  for _, pattern in ipairs(self._patterns) do
    local remove_head, count = str:gsub(pattern.head, "")
    if count > 0 then
      local result = remove_head:gsub(pattern.tail, "")
      return pattern.adjust(result)
    end
  end
  error("gave up unwrap string: " .. str)
end

return M
