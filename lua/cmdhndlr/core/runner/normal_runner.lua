local Handler = require("cmdhndlr.core.runner.handler")
local filelib = require("cmdhndlr.lib.file")

local NormalRunner = {}
NormalRunner.__index = NormalRunner

function NormalRunner.new(opts)
  local handler = Handler.new("normal_runner", opts)
  if type(handler) == "string" then
    local err = handler
    return err
  end
  vim.validate("run_file", handler.run_file, "function")
  vim.validate("run_string", handler.run_string, "function", true)

  local tbl = {
    working_dir = handler.decided_working_dir,
    full_name = handler.full_name,
    _bufnr = opts.bufnr,
    _handler = handler,
    _global_opts = opts,
  }
  return setmetatable(tbl, NormalRunner)
end

--- @param observer table
--- @param range table?
function NormalRunner.execute(self, observer, range)
  local ctx = require("cmdhndlr.core.runner.context").new(self._handler, self._global_opts, observer)
  if range ~= nil then
    return self:_run_range(ctx, range)
  end
  return self:_run_buffer(ctx)
end

function NormalRunner._run_range(self, ctx, range)
  if not self._handler.run_string then
    local err = ("`%s` does not support range"):format(self._handler.full_name)
    return require("cmdhndlr.vendor.promise").reject(err)
  end

  local str = require("cmdhndlr.lib.buffer_range").new(self._bufnr, range):to_string()
  return self._handler.run_string(ctx, str)
end

function NormalRunner._run_buffer(self, ctx)
  local path = self._handler.path_modifier(vim.api.nvim_buf_get_name(self._bufnr))
  if path ~= "" then
    return self._handler.run_file(ctx, path)
  end

  local str = require("cmdhndlr.lib.buffer_range").entire(self._bufnr):to_string()
  if self._handler.run_string then
    return self._handler.run_string(ctx, str)
  end

  return self._handler.run_file(ctx, filelib.temporary(str))
end

return NormalRunner
