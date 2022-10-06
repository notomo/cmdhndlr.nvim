local helper = require("cmdhndlr.test.helper")
local cmdhndlr = helper.require("cmdhndlr")

describe("lua/busted test runner", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  local handler_name = "lua/busted"

  it("can test buffer source", function()
    helper.test_data:create_file(
      "hoge_spec.lua",
      [[
describe("hoge", function()
  it('foo', function ()
    print("busted_test")
  end)
end)
]]
    )
    vim.cmd.edit("hoge_spec.lua")

    local job = cmdhndlr.test({ name = handler_name })
    helper.wait(job)

    assert.exists_pattern([[
busted_test]])
  end)

  it("can test a it in the nested describe by filter", function()
    helper.test_data:create_file(
      "hoge_spec.lua",
      [[
describe("hoge", function()
  describe('foo', function ()
    it('target', function ()
      print("OK")
    end)
    it('not', function ()
      print("NG")
    end)
  end)
  it('not', function ()
    print("NG")
  end)
end)
]]
    )
    vim.cmd.edit("hoge_spec.lua")

    local job = cmdhndlr.test({ name = handler_name, filter = "hoge foo target" })
    helper.wait(job)

    assert.exists_pattern([[OK]])
    assert.no.exists_pattern([[NG]])
  end)
end)
