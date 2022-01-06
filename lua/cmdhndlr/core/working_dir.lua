local M = {}

local WorkingDir = {}
WorkingDir.__index = WorkingDir
M.WorkingDir = WorkingDir

function WorkingDir.new(find_dir, find_marker)
  vim.validate({
    find_dir = { find_dir, "function", true },
    find_marker = { find_marker, "function", true },
  })

  local marker
  if find_marker then
    marker = find_marker()
  end

  local working_dir = "."
  if find_dir and not marker then
    working_dir = find_dir()
  elseif marker then
    working_dir = vim.fn.fnamemodify(marker, ":h")
  end
  vim.validate({ working_dir = { working_dir, "string" } })

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
