local Handler = require("cmdhndlr.core.runner.handler")

local TestRunner = {}
TestRunner.__index = TestRunner

function TestRunner.new(opts)
  local handler = Handler.new("test_runner", opts)
  if type(handler) == "string" then
    local err = handler
    return err
  end
  vim.validate("run_file", handler.run_file, "function")

  local tbl = {
    working_dir = handler.decided_working_dir,
    full_name = handler.full_name,
    _bufnr = opts.bufnr,
    _handler = handler,
    _global_opts = opts,
  }
  return setmetatable(tbl, TestRunner)
end

--- @param observer table
--- @param raw_filter string
--- @param is_leaf boolean
function TestRunner.execute(self, observer, raw_filter, is_leaf)
  local path = self._handler.path_modifier(vim.api.nvim_buf_get_name(self._bufnr))
  local filter = raw_filter ~= "" and raw_filter or nil
  local ctx = require("cmdhndlr.core.runner.context").new(self._handler, self._global_opts, observer)
  return self._handler.run_file(ctx, path, filter, is_leaf)
end

return TestRunner
