local helper = require("cmdhndlr.lib.testlib.helper")
local cmdhndlr = helper.require("cmdhndlr")

describe("cmdhndlr.run()", function()

  before_each(helper.before_each)
  after_each(helper.after_each)

  it("can run sync command", function()
    local result = cmdhndlr.run({
      name = "_test/file",
      runner_opts = {
        f = function()
          return "ok"
        end,
      },
    })
    assert.equal([[ok]], result.output)
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
    job:wait(100)
    assert.is_false(job:is_running())
    -- TODO
  end)

  it("raises error if there is no runner", function()
    local result = cmdhndlr.run()

    assert.is_nil(result)
    assert.exists_message([[no runner]])
  end)

  it("raises error if the runner is not found", function()
    local result = cmdhndlr.run({name = "invalid"})

    assert.is_nil(result)
    assert.exists_message([[not found runner: invalid]])
  end)

end)
