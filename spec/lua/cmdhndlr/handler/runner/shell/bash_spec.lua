local helper = require("cmdhndlr.lib.testlib.helper")
local cmdhndlr = helper.require("cmdhndlr")
local handler_name = "shell/bash"

describe(handler_name .. " runner", function()

  before_each(helper.before_each)
  after_each(helper.after_each)

  it("can run buffer source", function()
    helper.set_lines([[
echo hoge
echo hoge
]])

    local job = cmdhndlr.run({name = handler_name})
    helper.wait(job)

    assert.exists_pattern([[
hoge
hoge]])
  end)

  it("can run with range", function()
    helper.set_lines([[
echo hoge
echo foo
]])
    vim.cmd("normal! v$")

    local job = cmdhndlr.run({name = handler_name})
    helper.wait(job)

    assert.exists_pattern([[
hoge]])
  end)

end)
