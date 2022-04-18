local Handler = require("cmdhndlr.core.runner.handler").Handler

local TestRunner = {}
TestRunner.__index = TestRunner

function TestRunner.new(opts)
  local handler, err = Handler.new("test_runner", opts)
  if err ~= nil then
    return nil, err
  end
  vim.validate({
    run_file = { handler.run_file, "function" },
  })

  local tbl = {
    working_dir = handler.working_dir,
    path = handler.path,
    _bufnr = opts.bufnr,
    _handler = handler,
  }
  return setmetatable(tbl, TestRunner)
end

function TestRunner.execute(self, observer, raw_filter, is_leaf)
  vim.validate({ raw_filter = { raw_filter, "string" }, is_leaf = { is_leaf, "boolean" } })
  local path = vim.api.nvim_buf_get_name(self._bufnr)

  local filter = raw_filter ~= "" and raw_filter or nil
  local runner = self._handler:runner(observer)
  return self._handler.run_file(runner, path, filter, is_leaf)
end

return TestRunner
