local helper = require("cmdhndlr.lib.testlib.helper")
local cmdhndlr = helper.require("cmdhndlr")
local handler_name = "lua/busted"

describe(handler_name .. " test runner", function()

  before_each(helper.before_each)
  after_each(helper.after_each)

  it("can test buffer source", function()
    helper.new_file("hoge_spec.lua", [[
describe("hoge", function()
  it('foo', function ()
    print("busted_test")
  end)
end)
]])
    vim.cmd("edit hoge_spec.lua")

    local job = cmdhndlr.test({name = handler_name})
    helper.wait(job)

    assert.exists_pattern([[
busted_test]])
  end)

end)
