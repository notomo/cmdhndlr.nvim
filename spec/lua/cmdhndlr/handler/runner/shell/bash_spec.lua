local ntf = require("ntf")
local describe, it, before_each, after_each = ntf.describe, ntf.it, ntf.before_each, ntf.after_each
local helper = require("cmdhndlr.test.helper")
local cmdhndlr = require("cmdhndlr")
local assert = require("assertlib").typed(ntf.assert)

describe("shell/bash runner", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  local handler_name = "shell/bash"

  it("can run buffer source", function()
    helper.set_lines([[
echo hoge
echo hoge
]])

    local job = cmdhndlr.run({ name = handler_name })
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
    vim.cmd.normal({ args = { "v$" }, bang = true })

    local job = cmdhndlr.run({ name = handler_name })
    helper.wait(job)

    assert.exists_pattern([[
hoge]])
  end)
end)
