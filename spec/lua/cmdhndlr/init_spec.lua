local helper = require("cmdhndlr.lib.testlib.helper")
local cmdhndlr = helper.require("cmdhndlr")

describe("cmdhndlr.run()", function()
  before_each(function()
    helper.before_each()

    helper.register_normal_runner("_test/file", {
      opts = {
        f = function()
          return "not implemented"
        end,
      },
      run_file = function(self, path)
        return self.opts.f(self, path)
      end,
      run_string = function(self, str)
        return self.opts.f(self, str)
      end,
    })

    helper.register_normal_runner("_test/no_range", {
      run_file = function()
        return "run_file"
      end,
    })

    helper.register_normal_runner("_test/working_dir", {
      run_file = function() end,
      run_string = function(self)
        return self.working_dir:get()
      end,
      working_dir = require("cmdhndlr.util").working_dir.upward_pattern("dir1", "dir2"),
    })
  end)
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

  it("can hook sync command success", function()
    local hooked = false

    cmdhndlr.run({
      name = "_test/file",
      hooks = {
        success = function()
          hooked = true
        end,
      },
    })

    assert.is_true(hooked)
  end)

  it("can hook sync command failure", function()
    local hooked = false

    cmdhndlr.run({
      name = "_test/file",
      runner_opts = {
        f = function()
          return nil, "err"
        end,
      },
      hooks = {
        failure = function()
          hooked = true
        end,
      },
    })

    assert.is_true(hooked)
  end)

  it("can pass environment variables", function()
    local job = cmdhndlr.run({
      name = "_test/file",
      runner_opts = {
        f = function(self)
          return self.job_factory:create("echo $HOGE $BAR")
        end,
      },
      env = { HOGE = "FOO", BAR = "BAZ" },
    })
    helper.wait(job)
    assert.exists_pattern("FOO BAZ")
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
    cmdhndlr.setup({ normal_runner = { default = { [""] = "_test/file" } } })

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

    cmdhndlr.run({ name = "_test/working_dir" })

    assert.exists_pattern(helper.test_data_path .. "root$")
  end)

  it("can run async command", function()
    local job = cmdhndlr.run({
      name = "_test/file",
      runner_opts = {
        f = function(self)
          return self.job_factory:create({ "echo", "ok" })
        end,
      },
    })
    helper.wait(job)

    assert.exists_pattern("ok")
  end)

  it("can hook async command success", function()
    local hooked = false

    local job = cmdhndlr.run({
      name = "_test/file",
      runner_opts = {
        f = function(self)
          return self.job_factory:create({ "echo", "ok" })
        end,
      },
      hooks = {
        success = function()
          hooked = true
        end,
      },
    })
    helper.wait(job)

    assert.is_true(hooked)
  end)

  it("can hook async command failure", function()
    local hooked = false

    local job = cmdhndlr.run({
      name = "_test/file",
      runner_opts = {
        f = function(self)
          return self.job_factory:create({ "cat", "not_found" })
        end,
      },
      hooks = {
        failure = function()
          hooked = true
        end,
      },
    })
    helper.wait(job)

    assert.is_true(hooked)
  end)

  it("moves cursor to the bottom with sync command", function()
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

  it("moves cursor to the bottom with async command", function()
    cmdhndlr.run({
      name = "_test/file",
      runner_opts = {
        f = function(self)
          return self.job_factory:create({ "echo", "hoge" })
        end,
      },
    })
    assert.equals(vim.fn.line("$"), vim.fn.line("."))
  end)

  it("raises error if command is not found", function()
    cmdhndlr.run({
      name = "_test/file",
      runner_opts = {
        f = function(self)
          return self.job_factory:create({ "invalid_cmd" })
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
    local result = cmdhndlr.run({ name = "invalid" })

    assert.is_nil(result)
    assert.exists_message([[not found handler: normal_runner/invalid]])
  end)

  it("raises error if the runner does not support range", function()
    vim.cmd("normal! v")

    local result = cmdhndlr.run({ name = "_test/no_range" })

    assert.is_nil(result)
    assert.exists_message([[`_test/no_range` runner does not support range]])
  end)

  it("raises error if the runner raises no output error", function()
    helper.register_normal_runner("_test/no_output_error", {
      run_file = function()
        return nil, { msg = "not found parser" }
      end,
    })

    local result = cmdhndlr.run({ name = "_test/no_output_error" })

    assert.is_nil(result)
    assert.exists_message([[not found parser]])
    assert.window_count(1)
  end)

  it("can use runner that is not supported range in nofile buffer", function()
    cmdhndlr.run({ name = "_test/no_range" })

    assert.exists_pattern([[run_file]])
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

  it("can open in tab", function()
    cmdhndlr.run({
      name = "_test/file",
      layout = { type = "tab" },
      runner_opts = {
        f = function()
          return "tab"
        end,
      },
    })
    assert.tab_count(2)
  end)
end)

describe("cmdhndlr.test()", function()
  before_each(function()
    helper.before_each()

    helper.register_test_runner("_test/file", {
      opts = {
        f = function()
          return "not implemented"
        end,
      },
      run_file = function(self, path)
        return self.opts.f(self, path)
      end,
    })
  end)
  after_each(helper.after_each)

  it("can test async", function()
    local job = cmdhndlr.test({
      name = "_test/file",
      runner_opts = {
        f = function(self)
          return self.job_factory:create({ "echo", "ok" })
        end,
      },
    })
    helper.wait(job)

    assert.exists_pattern("ok")
    assert.exists_message("SUCCESS")
  end)

  it("can hook async command success", function()
    local hooked = false

    local job = cmdhndlr.test({
      name = "_test/file",
      runner_opts = {
        f = function(self)
          return self.job_factory:create({ "echo", "ok" })
        end,
      },
      hooks = {
        success = function()
          hooked = true
        end,
      },
    })
    helper.wait(job)

    assert.is_true(hooked)
  end)

  it("can hook async command failure", function()
    local hooked = false

    local job = cmdhndlr.test({
      name = "_test/file",
      runner_opts = {
        f = function(self)
          return self.job_factory:create({ "cat", "not_found" })
        end,
      },
      hooks = {
        failure = function()
          hooked = true
        end,
      },
    })
    helper.wait(job)

    assert.is_true(hooked)
  end)

  it("can run default test runner", function()
    cmdhndlr.setup({ test_runner = { default = { [""] = "_test/file" } } })

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
    local result = cmdhndlr.test({ name = "invalid" })

    assert.is_nil(result)
    assert.exists_message([[not found handler: test_runner/invalid]])
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

describe("cmdhndlr.build()", function()
  before_each(function()
    helper.before_each()

    helper.register_build_runner("_test/file", {
      opts = {
        f = function()
          return "not implemented"
        end,
      },
      build = function(self, path)
        return self.opts.f(self, path)
      end,
    })
  end)
  after_each(helper.after_each)

  it("can build async", function()
    local job = cmdhndlr.build({
      name = "_test/file",
      runner_opts = {
        f = function(self)
          return self.job_factory:create({ "echo", "ok" })
        end,
      },
    })
    helper.wait(job)

    assert.exists_pattern("ok")
    assert.exists_message("SUCCESS")
  end)
end)

describe("cmdhndlr.retry()", function()
  before_each(function()
    helper.before_each()

    helper.register_build_runner("_test/file", {
      opts = {
        f = function()
          return "not implemented"
        end,
      },
      build = function(self, path)
        return self.opts.f(self, path)
      end,
    })
  end)
  after_each(helper.after_each)

  it("can retry", function()
    local job1 = cmdhndlr.build({
      name = "_test/file",
      runner_opts = {
        f = function(self)
          return self.job_factory:create({ "echo", "ok" })
        end,
      },
    })
    helper.wait(job1)
    assert.exists_pattern("ok")

    local job2 = cmdhndlr.retry()
    helper.wait(job2)
    assert.exists_pattern("ok")
  end)

  it("can call multiple", function()
    local job1 = cmdhndlr.build({
      name = "_test/file",
      runner_opts = {
        f = function(self)
          return self.job_factory:create({ "echo", "ok" })
        end,
      },
    })
    helper.wait(job1)
    assert.exists_pattern("ok")

    local job2 = cmdhndlr.retry()
    helper.wait(job2)
    assert.exists_pattern("ok")

    local job3 = cmdhndlr.retry()
    helper.wait(job3)
    assert.exists_pattern("ok")
  end)

  it("raises error if not plugin buffer", function()
    cmdhndlr.retry()
    assert.exists_message([[not cmdhndlr buffer]])
  end)
end)

describe("cmdhndlr.input()", function()
  before_each(function()
    helper.before_each()

    helper.register_normal_runner("_test/file", {
      opts = {
        f = function()
          return "not implemented"
        end,
      },
      run_file = function(self, path)
        return self.opts.f(self, path)
      end,
    })
  end)
  after_each(helper.after_each)

  it("can input to stdin", function()
    local job = cmdhndlr.run({
      name = "_test/file",
      runner_opts = {
        f = function(self)
          return self.job_factory:create({ "cat" })
        end,
      },
    })
    cmdhndlr.input("test_input", { name = "normal_runner/_test/file" })
    cmdhndlr.input(vim.api.nvim_eval('"\\<C-c>"'), { name = "normal_runner/_test/file" })

    helper.wait(job)

    assert.exists_pattern([[Process exited]])
  end)

  it("raises error if not plugin buffer", function()
    cmdhndlr.input("test")
    assert.exists_message([[not found running buffer]])
  end)

  it("raises error if the command is not running", function()
    local job = cmdhndlr.run({
      name = "_test/file",
      runner_opts = {
        f = function(self)
          return self.job_factory:create({ "echo" })
        end,
      },
    })
    helper.wait(job)

    cmdhndlr.input("test_input", { name = "normal_runner/_test/file" })
    assert.exists_message([[not found running buffer]])
  end)
end)

describe("cmdhndlr.executed_runners()", function()
  before_each(function()
    helper.before_each()

    helper.register_normal_runner("_test/file", {
      opts = {
        f = function()
          return "not implemented"
        end,
      },
      run_file = function(self, path)
        return self.opts.f(self, path)
      end,
    })
  end)
  after_each(helper.after_each)

  it("returns empty if there is no context", function()
    local actual = cmdhndlr.executed_runners()
    assert.is_same({}, actual)
  end)

  it("returns executed runners", function()
    cmdhndlr.run({
      name = "_test/file",
      runner_opts = {
        f = function()
          return "ok"
        end,
      },
    })
    local bufnr = vim.api.nvim_get_current_buf()

    local actual = cmdhndlr.executed_runners()
    assert.same({ { name = "normal_runner/_test/file", bufnr = bufnr, is_running = false } }, actual)
  end)
end)
