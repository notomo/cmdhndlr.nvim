local Handler = require("cmdhndlr.core.runner.handler").Handler

local M = {}

local TestRunner = {}
M.TestRunner = TestRunner

function TestRunner.new(opts)
  local handler, err = Handler.new("test_runner", opts)
  if err ~= nil then
    return nil, err
  end
  vim.validate({
    run_file = { handler.run_file, "function" },
  })

  local tbl = {
    _bufnr = opts.bufnr,
    _handler = handler,
  }
  return setmetatable(tbl, TestRunner)
end

function TestRunner.__index(self, k)
  return rawget(TestRunner, k) or self._handler[k]
end

function TestRunner.execute(self, raw_filter, is_leaf)
  vim.validate({ raw_filter = { raw_filter, "string" }, is_leaf = { is_leaf, "boolean" } })
  local path = vim.api.nvim_buf_get_name(self._bufnr)

  local filter = raw_filter ~= "" and raw_filter or nil
  local output, err = self:run_file(path, filter, is_leaf)

  return self:result(output, err)
end

return M
