local M = {}

local handler = require("cmdhndlr.handler.normal_runner.make.make")
M.opts = vim.deepcopy(handler.opts)
M.opts.target = "test"

return setmetatable(M, {
  __index = function(_, k)
    return rawget(M, k) or handler[k]
  end,
})
