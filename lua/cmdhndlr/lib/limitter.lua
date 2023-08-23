local Limitter = {}
Limitter.__index = Limitter

function Limitter.new(limit, interval_ms)
  local tbl = {
    _limit = limit,
    _count = 0,
    _queue = {},
    _timer = vim.uv.new_timer(),
    _interval_ms = interval_ms,
  }
  local self = setmetatable(tbl, Limitter)
  self._start_worker = require("cmdhndlr.vendor.misclib.debounce").wrap(100, function()
    self:_start()
  end)
  return self
end

function Limitter.enqueue(self, f)
  self._count = self._count + 1

  local p
  if self._limit < self._count then
    p = require("cmdhndlr.vendor.promise").new(function(resolve)
      table.insert(self._queue, 1, {
        f = f,
        resolve = resolve,
      })
    end)
    self._start_worker()
  else
    p = f()
  end

  return p:finally(function()
    self._count = self._count - 1
  end)
end

function Limitter._start(self)
  self._timer:stop()
  self._timer:start(0, self._interval_ms, function()
    if self._count <= 0 then
      self._timer:stop()
      return
    end

    for _ = self._limit - 1, self._count, -1 do
      local e = table.remove(self._queue)
      if not e then
        break
      end
      vim.schedule(function()
        e.resolve(e.f())
      end)
    end
  end)
end

return Limitter
