local M = {}

function M.temporary(str)
  vim.validate({str = {str, "string"}})

  local path = vim.fn.tempname()
  local f = io.open(path, "w")
  f:write(str)
  f:close()

  return path
end

return M
