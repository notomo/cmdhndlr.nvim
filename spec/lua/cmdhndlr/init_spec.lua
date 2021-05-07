local helper = require("cmdhndlr.lib.testlib.helper")
local cmdhndlr = helper.require("cmdhndlr")

describe("cmdhndlr.run()", function()

  before_each(helper.before_each)
  after_each(helper.after_each)

  it("can run sync command", function()
    cmdhndlr.run({
      name = "_test/file",
      runner_opts = {
        f = function()
          return "ok"
        end,
      },
    })
    assert.exists_pattern("ok")
  end)

  it("can run with range", function()
    helper.set_lines([[
hoge
]])

    vim.cmd("normal! v")
    vim.cmd("normal! $")

    cmdhndlr.run({
      name = "_test/file",
      runner_opts = {
        f = function(_, str)
          return str .. "_foo"
        end,
      },
    })
    assert.exists_pattern("hoge_foo")
  end)

  it("can run async command", function()
    local job = cmdhndlr.run({
      name = "_test/file",
      runner_opts = {
        f = function(self)
          return self.job_factory:create({"echo", "ok"})
        end,
      },
    })
    helper.wait(job)

    assert.exists_pattern("ok")
  end)

  it("raises error if there is no runner", function()
    local result = cmdhndlr.run()

    assert.is_nil(result)
    assert.exists_message([[no handler]])
  end)

  it("raises error if the runner is not found", function()
    local result = cmdhndlr.run({name = "invalid"})

    assert.is_nil(result)
    assert.exists_message([[not found handler: runner.invalid]])
  end)

  it("raises error if the runner raises an error", function()
    cmdhndlr.run({
      name = "_test/file",
      runner_opts = {
        f = function()
          return nil, "runner specific error!"
        end,
      },
    })
    assert.exists_message([[runner specific error!]])
  end)

end)

describe("cmdhndlr.test()", function()

  before_each(helper.before_each)
  after_each(helper.after_each)

  it("can test async", function()
    local job = cmdhndlr.test({
      name = "_test/file",
      runner_opts = {
        f = function(self)
          return self.job_factory:create({"echo", "ok"})
        end,
      },
    })
    helper.wait(job)

    assert.exists_pattern("ok")
  end)

  it("raises error if there is no test runner", function()
    local result = cmdhndlr.test()

    assert.is_nil(result)
    assert.exists_message([[no handler]])
  end)

  it("raises error if the test runner is not found", function()
    local result = cmdhndlr.test({name = "invalid"})

    assert.is_nil(result)
    assert.exists_message([[not found handler: test_runner.invalid]])
  end)

  it("raises error if the test runner raises an error", function()
    cmdhndlr.test({
      name = "_test/file",
      runner_opts = {
        f = function()
          return nil, "test_runner specific error!"
        end,
      },
    })
    assert.exists_message([[test_runner specific error!]])
  end)

end)
