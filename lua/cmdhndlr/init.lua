local M = {}

function M.run(opts)
  return require("cmdhndlr.command").run(opts)
end

function M.test(opts)
  return require("cmdhndlr.command").test(opts)
end

function M.build(opts)
  return require("cmdhndlr.command").build(opts)
end

function M.retry()
  return require("cmdhndlr.command").retry()
end

function M.input(text, opts)
  require("cmdhndlr.command").input(text, opts)
end

function M.setup(config)
  require("cmdhndlr.command").setup(config)
end

function M.executed_runners()
  return require("cmdhndlr.command").executed_runners()
end

function M.execute(name, opts)
  return require("cmdhndlr.command").execute(name, opts)
end

function M.runners()
  return require("cmdhndlr.command").runners()
end

return M
