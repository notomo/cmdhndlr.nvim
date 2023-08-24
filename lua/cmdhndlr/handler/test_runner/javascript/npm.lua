local handler = require("cmdhndlr.handler.normal_runner.javascript.npm")

local M = vim.deepcopy(handler)
M.opts.target = "test"

return M
