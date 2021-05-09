local M = {}

local WorkingDir = {}
WorkingDir.__index = WorkingDir
M.WorkingDir = WorkingDir

function WorkingDir.new(get_dir)
  vim.validate({get_dir = {get_dir, "function", true}})

  local working_dir = "."
  if get_dir then
    working_dir = get_dir()
    vim.validate({working_dir = {working_dir, "string"}})
  end

  local tbl = {_working_dir = working_dir}
  return setmetatable(tbl, WorkingDir)
end

function WorkingDir.get(self)
  return self._working_dir
end

function WorkingDir.set_current(self)
  vim.cmd("silent lcd " .. self._working_dir)
end

return M
