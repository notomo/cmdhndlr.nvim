local M = {}

function M.to_bottom(bufnr, window_id)
  vim.validate({ bufnr = { bufnr, "number" }, window_id = { window_id, "number" } })
  local count = vim.api.nvim_buf_line_count(bufnr)
  vim.api.nvim_win_set_cursor(window_id, { count, 0 })
end

return M
