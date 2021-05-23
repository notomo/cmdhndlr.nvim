local M = {}

function M.run_file(_, path)
  local ok, result = pcall(vim.api.nvim_exec, "source " .. path, true)
  if not ok then
    return nil, result
  end
  return result, nil
end

function M.run_string(_, str)
  local ok, result = pcall(vim.api.nvim_exec, str, true)
  if not ok then
    return nil, result
  end
  return result, nil
end

return M
