local handler = require("cmdhndlr.handler.normal_runner.make.make")

local M = vim.deepcopy(handler)
M.opts.target = "build"
M.build = handler.run_file

return M
