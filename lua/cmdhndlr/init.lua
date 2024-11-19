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

function M.build_as_job(opts)
  return require("cmdhndlr.command").build_as_job(opts)
end

function M.format(opts)
  return require("cmdhndlr.command").format(opts)
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

function M.execute(full_name, opts)
  return require("cmdhndlr.command").execute(full_name, opts)
end

function M.enabled(typ, opts)
  return require("cmdhndlr.command").enabled(typ, opts)
end

function M.get(full_name)
  return require("cmdhndlr.command").get(full_name)
end

function M.runners()
  return require("cmdhndlr.command").runners()
end

return M
