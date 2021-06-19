local M = {}

function M.run_file(self, path)
  local ok, result = pcall(vim.api.nvim_exec, "luafile " .. self.filelib.escape(path), true)
  if not ok then
    return nil, result
  end
  return result, nil
end

function M.run_string(_, str)
  local ok, result = pcall(vim.api.nvim_exec, "lua << EOF\n" .. str .. "\nEOF", true)
  if not ok then
    return nil, result
  end
  return result, nil
end

return M
