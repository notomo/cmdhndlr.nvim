local filelib = require("cmdhndlr.lib.file")

local M = {}

function M.upward_pattern(...)
  local args = {...}
  return function()
    return M._upward_pattern(unpack(args))
  end
end

function M._upward_pattern(...)
  for _, pattern in ipairs({...}) do
    local dir = filelib.find_upward_dir(pattern)
    if dir ~= nil then
      return dir
    end
  end
  return "."
end

return M
