local M = {}

function M.temporary(str)
  vim.validate({str = {str, "string"}})

  local path = vim.fn.tempname()
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

return M
