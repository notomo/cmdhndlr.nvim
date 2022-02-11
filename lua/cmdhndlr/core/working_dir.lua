local M = {}

local WorkingDir = {}
WorkingDir.__index = WorkingDir
M.WorkingDir = WorkingDir

function WorkingDir.new(working_dir, marker)
  vim.validate({
    working_dir = { working_dir, "string", true },
    marker = { marker, "string", true },
  })
  if marker then
    working_dir = vim.fn.fnamemodify(marker, ":h")
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
  vim.cmd("silent lcd " .. self._working_dir)
end

return M
