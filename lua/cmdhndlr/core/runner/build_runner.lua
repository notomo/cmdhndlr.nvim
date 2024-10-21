local Handler = require("cmdhndlr.core.runner.handler")

local BuildRunner = {}
BuildRunner.__index = BuildRunner

function BuildRunner.new(opts)
  local handler = Handler.new("build_runner", opts)
  if type(handler) == "string" then
    local err = handler
    return err
  end
  vim.validate("build", handler.build, "function")

  local tbl = {
    working_dir = handler.decided_working_dir,
    full_name = handler.full_name,
    _bufnr = opts.bufnr,
    _handler = handler,
    _global_opts = opts,
  }
  return setmetatable(tbl, BuildRunner)
end

function BuildRunner.execute(self, observer)
  local path = vim.api.nvim_buf_get_name(self._bufnr)
  local ctx = require("cmdhndlr.core.runner.context").new(self._handler, self._global_opts, observer)
  return self._handler.build(ctx, path)
end

return BuildRunner
