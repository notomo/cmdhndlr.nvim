local M = {}

M.cmd = "vusted"
M.working_dir = require("cmdhndlr.util.working_dir").upward_pattern(".git")

local handler = require("cmdhndlr.handler.test_runner.lua.busted")
return setmetatable(M, {
  __index = function(_, k)
    return rawget(M, k) or handler[k]
  end,
})
