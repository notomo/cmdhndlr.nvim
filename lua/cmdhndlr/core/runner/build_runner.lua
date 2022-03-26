local Handler = require("cmdhndlr.core.runner.handler").Handler

local M = {}

local BuildRunner = {}
M.BuildRunner = BuildRunner

function BuildRunner.new(observer, opts)
  local handler, err = Handler.new("build_runner", observer, opts)
  if err ~= nil then
    return nil, err
  end
  vim.validate({ build = { handler.build, "function" } })

  local tbl = { _bufnr = opts.bufnr, _handler = handler }
  return setmetatable(tbl, BuildRunner)
end

function BuildRunner.__index(self, k)
  return rawget(BuildRunner, k) or self._handler[k]
end

function BuildRunner.execute(self)
  local path = vim.api.nvim_buf_get_name(self._bufnr)
  return self:build(path)
end

return M
