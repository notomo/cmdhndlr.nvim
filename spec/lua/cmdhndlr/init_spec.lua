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

  it("can run default runner", function()
    cmdhndlr.setup({runner = {default = {[""] = "_test/file"}}})

    cmdhndlr.run({
      runner_opts = {
        f = function()
          return "default"
        end,
      },
    })

    assert.exists_pattern("default")
  end)

  it("can run with runner's working_dir", function()
    helper.new_directory("root/dir")
    helper.new_directory("root/dir2")
    helper.cd("root/dir")

    cmdhndlr.run({name = "_test/working_dir"})

    assert.exists_pattern(helper.test_data_path .. "root$")
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

  it("moves cursor to the bottom", function()
    cmdhndlr.run({
      name = "_test/file",
      runner_opts = {
        f = function()
          return [[
foo
bar]]
        end,
      },
    })
    assert.current_line("bar")
  end)

  it("raises error if command is not found", function()
    cmdhndlr.run({
      name = "_test/file",
      runner_opts = {
        f = function(self)
          return self.job_factory:create({"invalid_cmd"})
        end,
      },
    })
    assert.exists_pattern([['invalid_cmd' is not executable]])
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

  it("raises error if the runner does not support range", function()
    vim.cmd("normal! v")

    local result = cmdhndlr.run({name = "_test/no_range"})

    assert.is_nil(result)
    assert.exists_message([[`_test/no_range` runner does not support range]])
  end)

  it("shows error if the runner raises an error", function()
    cmdhndlr.run({
      name = "_test/file",
      runner_opts = {
        f = function()
          return nil, "runner specific error!"
        end,
      },
    })
    assert.exists_pattern([[runner specific error!]])
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

  it("can run default test runner", function()
    cmdhndlr.setup({test_runner = {default = {[""] = "_test/file"}}})

    cmdhndlr.test({
      runner_opts = {
        f = function()
          return "default"
        end,
      },
    })

    assert.exists_pattern("default")
  end)

  it("moves cursor to the bottom", function()
    cmdhndlr.test({
      name = "_test/file",
      runner_opts = {
        f = function()
          return [[
foo
bar]]
        end,
      },
    })
    assert.current_line("bar")
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

  it("shows error if the test runner raises an error", function()
    cmdhndlr.test({
      name = "_test/file",
      runner_opts = {
        f = function()
          return nil, "test_runner specific error!"
        end,
      },
    })
    assert.exists_pattern([[test_runner specific error!]])
  end)

end)
