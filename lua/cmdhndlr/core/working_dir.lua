local WorkingDir = {}
WorkingDir.__index = WorkingDir

--- @param working_dir string?
--- @param marker string?
function WorkingDir.new(working_dir, marker)
  if marker then
    working_dir = vim.fs.dirname(marker)
  end
  working_dir = working_dir or "."
  local tbl = { _working_dir = working_dir, _marker = marker }
  return setmetatable(tbl, WorkingDir)
end

function WorkingDir.get(self)
  return self._working_dir
end

function WorkingDir.marker(self)
  return self._marker
end

--- @param bufnr integer
function WorkingDir.set_to_buffer(self, bufnr)
  vim.api.nvim_buf_call(bufnr, function()
    vim.fn.chdir(self._working_dir, "buffer")
  end)
end

return WorkingDir
