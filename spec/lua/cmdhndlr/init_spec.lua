local helper = require("cmdhndlr.lib.testlib.helper")
local cmdhndlr = helper.require("cmdhndlr")

describe("cmdhndlr.run()", function()
  before_each(function()
    helper.before_each()

    helper.register_normal_runner("_test/file", {
      opts = {
        f = function()
          error("not implemented")
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
      run_file = function(self)
        return self.job_factory:create({ "echo", "run_file" })
      end,
    })

    helper.register_normal_runner("_test/working_dir", {
      run_file = function() end,
      run_string = function(self)
        local parts = vim.split(self.working_dir:get(), "/", true)
        return self.job_factory:create({ "echo", parts[#parts] })
      end,
      working_dir = require("cmdhndlr.util").working_dir.upward_pattern("dir1", "dir2"),
    })
  end)
  after_each(helper.after_each)

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

    vim.cmd.normal({ args = { "v" }, bang = true })
    vim.cmd.normal({ args = { "$" }, bang = true })

    local job = cmdhndlr.run({
      name = "_test/file",
      runner_opts = {
        f = function(self, str)
          return self.job_factory:create({ "echo", str .. "_foo" })
        end,
      },
    })
    helper.wait(job)

    assert.exists_pattern("hoge_foo")
  end)

  it("can run default runner", function()
    cmdhndlr.setup({ normal_runner = { default = { [""] = "_test/file" } } })

    local job = cmdhndlr.run({
      runner_opts = {
        f = function(self)
          return self.job_factory:create({ "echo", "default" })
        end,
      },
    })
    helper.wait(job)

    assert.exists_pattern("default")
  end)

  it("can run with runner's working_dir", function()
    helper.test_data:create_dir("root/dir")
    helper.test_data:create_dir("root/dir2")
    helper.test_data:cd("root/dir")

    local job = cmdhndlr.run({ name = "_test/working_dir" })
    helper.wait(job)

    assert.exists_pattern("root")
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
    assert.exists_message("STARTING: echo ok")
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

  it("can hook async command pre_execute", function()
    local executed

    local job = cmdhndlr.run({
      name = "_test/file",
      runner_opts = {
        f = function(self)
          return self.job_factory:create({ "echo", "ok" })
        end,
      },
      hooks = {
        pre_execute = function(cmd)
          executed = cmd
        end,
      },
    })
    helper.wait(job)

    assert.is_same({ "echo", "ok" }, executed)
  end)

  it("moves cursor to the bottom with async command", function()
    local job = cmdhndlr.run({
      name = "_test/file",
      runner_opts = {
        f = function(self)
          return self.job_factory:create([[echo "foo
bar"]])
        end,
      },
    })
    helper.wait(job)

    assert.is_true(vim.fn.line("$") > 2)
  end)

  it("raises error if command is not found", function()
    local job = cmdhndlr.run({
      name = "_test/file",
      runner_opts = {
        f = function(self)
          return self.job_factory:create({ "invalid_cmd" })
        end,
      },
    })
    helper.wait(job)

    assert.exists_message([['invalid_cmd' is not executable]])
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
    vim.cmd.normal({ args = { "v" }, bang = true })

    local job = cmdhndlr.run({ name = "_test/no_range" })
    helper.wait(job)

    assert.exists_message([[`_test/no_range` runner does not support range]])
  end)

  it("can use runner that is not supported range in nofile buffer", function()
    local job = cmdhndlr.run({ name = "_test/no_range" })
    helper.wait(job)

    assert.exists_pattern([[run_file]])
  end)

  it("can open in tab", function()
    cmdhndlr.run({
      name = "_test/file",
      layout = { type = "tab" },
      runner_opts = {
        f = function(self)
          return self.job_factory:create("echo tab")
        end,
      },
    })
    assert.tab_count(2)
  end)

  it("can use buffer local setting", function()
    vim.b.cmdhndlr = { normal_runner = "_test/buffer_local" }

    local called = false
    helper.register_normal_runner("_test/buffer_local", {
      run_file = function(self)
        called = true
        return self.job_factory:create({ "echo" })
      end,
    })

    cmdhndlr.run()

    assert.is_true(called)
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
    assert.exists_message("STARTING: echo ok")
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

  it("can hook async command pre_execute", function()
    local executed

    local job = cmdhndlr.test({
      name = "_test/file",
      runner_opts = {
        f = function(self)
          return self.job_factory:create({ "echo", "ok" })
        end,
      },
      hooks = {
        pre_execute = function(cmd)
          executed = cmd
        end,
      },
    })
    helper.wait(job)

    assert.is_same({ "echo", "ok" }, executed)
  end)

  it("can run default test runner", function()
    cmdhndlr.setup({ test_runner = { default = { [""] = "_test/file" } } })

    local job = cmdhndlr.test({
      runner_opts = {
        f = function(self)
          return self.job_factory:create([[echo default]])
        end,
      },
    })
    helper.wait(job)

    assert.exists_pattern("default")
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
end)

describe("cmdhndlr.build()", function()
  before_each(function()
    helper.before_each()

    helper.register_build_runner("_test/file", {
      opts = {
        f = function()
          error("not implemented")
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
    assert.exists_message("STARTING: echo ok")
    assert.exists_message("SUCCESS")
  end)
end)

describe("cmdhndlr.retry()", function()
  before_each(function()
    helper.before_each()

    helper.register_build_runner("_test/file", {
      opts = {
        f = function()
          error("not implemented")
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
    assert.exists_message([[no buffer]])
  end)
end)

describe("cmdhndlr.input()", function()
  before_each(function()
    helper.before_each()

    helper.register_normal_runner("_test/file", {
      opts = {
        f = function()
          error("not implemented")
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

    assert.exists_pattern([[test_input]])
  end)

  it("raises error if not plugin buffer", function()
    cmdhndlr.input("test")
    assert.exists_message([[no running runner: no buffer]])
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
    assert.exists_message([[no running runner: not found: normal_runner/_test/file]])
  end)
end)

describe("cmdhndlr.executed_runners()", function()
  before_each(function()
    helper.before_each()

    helper.register_normal_runner("_test/file", {
      opts = {
        f = function()
          error("not implemented")
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
    local job = cmdhndlr.run({
      name = "_test/file",
      runner_opts = {
        f = function(self)
          return self.job_factory:create("echo ok")
        end,
      },
    })
    helper.wait(job)

    local bufnr = vim.api.nvim_get_current_buf()

    local actual = cmdhndlr.executed_runners()
    assert.same({ { name = "normal_runner/_test/file", bufnr = bufnr, is_running = false } }, actual)
  end)
end)

describe("cmdhndlr.execute()", function()
  before_each(function()
    helper.before_each()

    helper.register_normal_runner("_test/file", {
      opts = {
        f = function()
          error("not implemented")
        end,
      },
      run_file = function(self, path)
        return self.opts.f(self, path)
      end,
    })
  end)
  after_each(helper.after_each)

  it("can execute runner by name", function()
    local job = cmdhndlr.execute("normal_runner/_test/file", {
      name = "_test/file",
      runner_opts = {
        f = function(self)
          return self.job_factory:create("echo ok")
        end,
      },
    })
    helper.wait(job)

    assert.exists_pattern("ok")
  end)
end)

describe("cmdhndlr.runners()", function()
  before_each(function()
    helper.before_each()

    helper.register_normal_runner("_test/file", {
      run_file = function()
        error("not implemented")
      end,
    })
  end)
  after_each(helper.after_each)

  it("returns runners including registered manually", function()
    local actual = cmdhndlr.runners()
    assert.same({ name = "normal_runner/_test/file" }, actual[#actual])
  end)
end)
