local helper = require("cmdhndlr.lib.testlib.helper")
local cmdhndlr = helper.require("cmdhndlr")

describe("vim/lua runner", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  local handler_name = "vim/lua"

  it("can run buffer source", function()
    helper.set_lines([[
print("lua")
print("lua")
]])

    cmdhndlr.run({ name = handler_name })

    assert.exists_pattern([[
lua
lua]])
  end)

  it("can run with range", function()
    helper.set_lines([[
print("lua")
print("lua")
]])
    vim.cmd("normal! v$")

    cmdhndlr.run({ name = handler_name })

    assert.exists_pattern([[
lua]])
  end)

  it("shows error on error", function()
    helper.set_lines([[
error("error!")
]])

    cmdhndlr.run({ name = handler_name })

    assert.exists_pattern([[
error!]])
  end)
end)
