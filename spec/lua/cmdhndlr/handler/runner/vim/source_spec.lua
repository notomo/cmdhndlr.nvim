local helper = require("cmdhndlr.lib.testlib.helper")
local cmdhndlr = helper.require("cmdhndlr")

describe("vim/source runner", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  local handler_name = "vim/source"

  it("can run buffer source", function()
    helper.set_lines([[
echomsg 'source'
echomsg 'source'
]])

    cmdhndlr.run({ name = handler_name })

    assert.exists_pattern([[
source
source]])
  end)

  it("can run with range", function()
    helper.set_lines([[
echomsg 'source'
echomsg 'source'
]])
    vim.cmd("normal! v$")

    cmdhndlr.run({ name = handler_name })

    assert.exists_pattern([[
source]])
  end)

  it("shows error on error", function()
    helper.set_lines([[
echoerr 'error!'
]])

    cmdhndlr.run({ name = handler_name })

    assert.exists_pattern([[
error!]])
  end)
end)
