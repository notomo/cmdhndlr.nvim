local M = {}

local BufferRange = {}
BufferRange.__index = BufferRange
M.BufferRange = BufferRange

function BufferRange.new(bufnr, raw_range)
  vim.validate({bufnr = {bufnr, "number"}, raw_range = {raw_range, "table"}})
  local tbl = {_bufnr = bufnr, _range = raw_range}
  return setmetatable(tbl, BufferRange)
end

function BufferRange.entire(bufnr)
  return BufferRange.new(bufnr, {first = 1, last = vim.api.nvim_buf_line_count(bufnr)})
end

function BufferRange.to_string(self)
  local lines = vim.api.nvim_buf_get_lines(self._bufnr, self._range.first - 1, self._range.last, false)
  return table.concat(lines, "\n")
end

return M
