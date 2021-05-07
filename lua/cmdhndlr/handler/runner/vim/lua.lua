local M = {}

function M.run_file(_, path)
  local _, result = pcall(vim.api.nvim_exec, "luafile " .. path, true)
  return result, nil
end

function M.run_string(_, str)
  local _, result = pcall(vim.api.nvim_exec, "lua << EOF\n" .. str .. "\nEOF", true)
  return result, nil
end

return M
