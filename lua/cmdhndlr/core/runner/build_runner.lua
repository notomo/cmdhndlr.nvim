local Handler = require("cmdhndlr.core.runner.handler").Handler

local M = {}

local BuildRunner = {}
M.BuildRunner = BuildRunner

function BuildRunner.new(opts)
  local handler, err = Handler.new("build_runner", opts)
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
  local info_factory = self:info_factory()
  local output, err = self:build(path)
  return self:result(info_factory, output, err)
end

return M
