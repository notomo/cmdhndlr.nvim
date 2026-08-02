local ntf = require("ntf")
local describe, it, before_each, after_each = ntf.describe, ntf.it, ntf.before_each, ntf.after_each
local helper = require("cmdhndlr.test.helper")
local cmdhndlr = require("cmdhndlr")
local assert = require("assertlib").typed(ntf.assert)

describe("lua/ntf test runner", function()
  before_each(function()
    helper.before_each()

    local bin_dir = vim.fs.dirname(vim.api.nvim_get_runtime_file("bin/ntf", false)[1])
    local separator = vim.fn.has("win32") == 1 and ";" or ":"
    vim.env.PATH = bin_dir .. separator .. vim.env.PATH
  end)
  after_each(helper.after_each)

  local handler_name = "lua/ntf"

  it("can test buffer source", function()
    helper.test_data:create_file(
      "hoge_spec.lua",
      [[
local ntf = require("ntf")
local describe, it = ntf.describe, ntf.it

describe("hoge", function()
  it('foo', function ()
    print("ntf_test")
  end)
end)
]]
    )
    vim.cmd.edit("hoge_spec.lua")

    local job = cmdhndlr.test({ name = handler_name })
    helper.wait(job)

    assert.exists_pattern([[
ntf_test]])
  end)

  it("can test a it in the nested describe by filter", function()
    helper.test_data:create_file(
      "hoge_spec.lua",
      [[
local ntf = require("ntf")
local describe, it = ntf.describe, ntf.it

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
