local helper = require("cmdhndlr.test.helper")
local Limitter = helper.require("cmdhndlr.lib.limitter")
local assert = require("assertlib").typed(assert)

describe("limitter", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("limits concurrent promise count", function()
    local limitter = Limitter.new(2, 10)

    local called1 = false
    local p1 = limitter:enqueue(function()
      called1 = true
      return require("cmdhndlr.vendor.promise").resolve():next(function() end)
    end)

    local called2 = false
    local p2 = limitter:enqueue(function()
      called2 = true
      return require("cmdhndlr.vendor.promise").resolve():next(function() end)
    end)

    local called3 = false
    local p3 = limitter:enqueue(function()
      called3 = true
      return require("cmdhndlr.vendor.promise").resolve():next(function() end)
    end)

    assert.is_true(called1)
    assert.is_true(called2)
    assert.is_false(called3)

    helper.wait(p1)
    helper.wait(p2)
    helper.wait(p3)

    assert.is_true(called3)
  end)
end)
