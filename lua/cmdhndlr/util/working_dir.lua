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

function M.upward_marker(...)
  local args = {...}
  return function()
    return M._upward_marker(unpack(args))
  end
end

function M._upward_marker(...)
  for _, pattern in ipairs({...}) do
    local file = filelib.find_upward_file(pattern)
    if file ~= nil then
      return file
    end
  end
  return nil
end

return M
