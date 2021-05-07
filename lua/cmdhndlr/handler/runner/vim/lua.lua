local M = {}

function M.run_file(_, path)
  return vim.api.nvim_exec("luafile " .. path, true)
end

function M.run_string(_, str)
  return vim.api.nvim_exec("lua << EOF\n" .. str .. "\nEOF", true)
end

return M
