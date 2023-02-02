local M = {}

function M.temporary(str)
  vim.validate({ str = { str, "string", true } })

  local path = vim.fn.tempname()
  if not str then
    return path
  end

  local f = io.open(path, "w")
  f:write(str)
  f:close()
  return path
end

function M.find_upward_dir(child_pattern)
  local found_file = vim.fn.findfile(child_pattern, ".;")
  if found_file ~= "" then
    return vim.fn.fnamemodify(found_file, ":p:h")
  end

  local found_dir = vim.fn.finddir(child_pattern, ".;")
  if found_dir ~= "" then
    return vim.fn.fnamemodify(found_dir, ":p:h:h")
  end

  return nil
end

function M.find_upward_file(child_pattern)
  local found_file = vim.fn.findfile(child_pattern, ".;")
  if found_file ~= "" then
    return vim.fn.fnamemodify(found_file, ":p")
  end
  return nil
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
