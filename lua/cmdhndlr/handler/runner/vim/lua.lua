local M = {}

function M.run_file(_, path)
  return vim.api.nvim_exec("luafile " .. path, true)
end

return M
