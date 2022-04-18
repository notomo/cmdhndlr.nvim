local Handler = require("cmdhndlr.core.runner.handler").Handler

local BuildRunner = {}
BuildRunner.__index = BuildRunner

function BuildRunner.new(opts)
  local handler, err = Handler.new("build_runner", opts)
  if err ~= nil then
    return nil, err
  end
  vim.validate({ build = { handler.build, "function" } })

  local tbl = {
    working_dir = handler.working_dir,
    path = handler.path,
    _bufnr = opts.bufnr,
    _handler = handler,
  }
  return setmetatable(tbl, BuildRunner)
end

function BuildRunner.execute(self, observer)
  local path = vim.api.nvim_buf_get_name(self._bufnr)
  local runner = self._handler:runner(observer)
  return self._handler.build(runner, path)
end

return BuildRunner
