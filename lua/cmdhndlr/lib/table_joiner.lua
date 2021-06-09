local M = {}

local TableJoiner = {}
TableJoiner.__index = TableJoiner
M.TableJoiner = TableJoiner

function TableJoiner.new()
  local tbl = {_holders = {}}
  return setmetatable(tbl, TableJoiner)
end

function TableJoiner.add(self, holder)
  vim.validate({holder = {holder, "table"}})

  local current_first = holder[1]
  local before = self:last() or {}
  local before_last = before[#before]

  if current_first and before_last and current_first.id == before_last.id then
    vim.list_extend(before, {unpack(holder, 2)})
    return
  end
  table.insert(self._holders, holder)
end

function TableJoiner.last(self)
  return self._holders[#self._holders]
end

return M
