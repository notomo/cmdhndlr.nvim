local Handler = require("cmdhndlr.core.handler").Handler

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

function TestRunner.execute(self, raw_filter)
  vim.validate({ raw_filter = { raw_filter, "string" } })
  local path = vim.api.nvim_buf_get_name(self._bufnr)

  local info_factory = self:info_factory()
  local filter = raw_filter ~= "" and raw_filter or nil
  local output, err = self:run_file(path, filter)

  return self:result(info_factory, output, err)
end

return M
