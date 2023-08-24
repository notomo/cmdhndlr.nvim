local handler = require("cmdhndlr.handler.test_runner.lua.busted")

local M = vim.deepcopy(handler)
M.opts.cmd = "vusted"
M.working_dir = require("cmdhndlr.util.working_dir").upward_pattern(".git")

return M
