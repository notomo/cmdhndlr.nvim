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
  return require("cmdhndlr.command").input(text, opts)
end

function M.setup(config)
  return require("cmdhndlr.command").setup(config)
end

function M.executed_runners()
  return require("cmdhndlr.command").executed_runners()
end

return M
