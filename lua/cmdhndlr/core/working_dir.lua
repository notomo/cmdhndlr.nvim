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

function WorkingDir.set_current(self)
  vim.fn.chdir(self._working_dir, "window")
end

return WorkingDir
