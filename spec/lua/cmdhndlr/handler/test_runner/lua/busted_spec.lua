local helper = require("cmdhndlr.lib.testlib.helper")
local cmdhndlr = helper.require("cmdhndlr")
local handler_name = "lua/busted"

describe(handler_name .. " test runner", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("can test buffer source", function()
    helper.new_file(
      "hoge_spec.lua",
      [[
describe("hoge", function()
  it('foo', function ()
    print("busted_test")
  end)
end)
]]
    )
    vim.cmd("edit hoge_spec.lua")

    local job = cmdhndlr.test({ name = handler_name })
    helper.wait(job)

    assert.exists_pattern([[
busted_test]])
  end)

  it("can test a describe under the cursor", function()
    helper.use_parsers()
    helper.new_file(
      "hoge_spec.lua",
      [[
describe("not", function()
  it('hoge', function ()
    print("NG")
  end)
end)

describe("target", function()
  it('hoge', function ()
    print("OK")
  end)
end)
]]
    )
    vim.cmd("edit hoge_spec.lua")
    helper.search("target")

    local job = cmdhndlr.test({ name = handler_name, scope = "cursor" })
    helper.wait(job)

    assert.exists_pattern([[OK]])
    assert.no.exists_pattern([[NG]])
  end)

  it("can test a it under the cursor", function()
    helper.use_parsers()
    helper.new_file(
      "hoge_spec.lua",
      [[
describe("hoge", function()
  it('target', function ()
    print("OK")
  end)
  it('not', function ()
    print("NG")
  end)
end)
]]
    )
    vim.cmd("edit hoge_spec.lua")
    helper.search("target")

    local job = cmdhndlr.test({ name = handler_name, scope = "cursor" })
    helper.wait(job)

    assert.exists_pattern([[OK]])
    assert.no.exists_pattern([[NG]])
  end)

  it("can test a it in the nested describe under the cursor", function()
    helper.use_parsers()
    helper.new_file(
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
    vim.cmd("edit hoge_spec.lua")
    helper.search("target")

    local job = cmdhndlr.test({ name = handler_name, scope = "cursor" })
    helper.wait(job)

    assert.exists_pattern([[OK]])
    assert.no.exists_pattern([[NG]])
  end)
end)
