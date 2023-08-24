local handler = require("cmdhndlr.handler.normal_runner.make.make")

local M = vim.deepcopy(handler)
M.opts.target = "test"

return M
