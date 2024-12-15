local M = {}

--- @param str string?
function M.temporary(str)
  local path = vim.fn.tempname()
  if not str then
    return path
  end

  local f = io.open(path, "w")
  assert(f, "failed to open temporary file: " .. path)
  f:write(str)
  f:close()
  return path
end

function M.escape(path)
  return ([[`='%s'`]]):format(path:gsub("'", "''"))
end

function M.read_all(path)
  local f = io.open(path, "r")
  if not f then
    return nil, "cannot read: " .. path
  end
  if vim.fn.isdirectory(path) == 1 then
    return nil, "directory: " .. path
  end
  local str = f:read("*a")
  f:close()
  return str, nil
end

return M
