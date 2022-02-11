local M = {}
M.__index = M

function M.new(bufnr, raw_range)
  vim.validate({ bufnr = { bufnr, "number" }, raw_range = { raw_range, "table" } })
  local tbl = { _bufnr = bufnr, _range = raw_range }
  return setmetatable(tbl, M)
end

function M.entire(bufnr)
  return M.new(bufnr, { first = 1, last = vim.api.nvim_buf_line_count(bufnr) })
end

function M.to_string(self)
  local lines = vim.api.nvim_buf_get_lines(self._bufnr, self._range.first - 1, self._range.last, false)
  return table.concat(lines, "\n")
end

return M
