local JobFactory = require("cmdhndlr.core.job_factory").JobFactory
local WorkingDir = require("cmdhndlr.core.working_dir").WorkingDir
local RunnerResult = require("cmdhndlr.core.runner_result")
local modulelib = require("cmdhndlr.vendor.module")
local filelib = require("cmdhndlr.lib.file")

local M = {}

M.registered = {}

local Handler = { registered = {} }
M.Handler = Handler

function Handler.new(typ, opts)
  vim.validate({
    type = { typ, "string" },
    opts = { opts, "table" },
  })

  local filetype = vim.bo[opts.bufnr].filetype
  local default = require("cmdhndlr.core.custom").config[typ].default[filetype]
  local name = opts.name
  if name == "" and default ~= nil then
    name = default
  end
  if name == "" then
    return nil, "no handler"
  end

  local path = M._path(typ, name)
  local handler, err = Handler._find(path)
  if err then
    return nil, err
  end
  handler.opts = handler.opts or {}
  handler.working_dir = handler.working_dir or function()
    return nil
  end
  handler.working_dir_marker = handler.working_dir_marker or function()
    return nil
  end

  local working_dir = WorkingDir.new(
    opts.working_dir() or handler.working_dir(),
    opts.working_dir_marker() or handler.working_dir_marker()
  )
  local output_bunfr = vim.api.nvim_create_buf(false, true)
  local tbl = {
    name = name,
    path = M._path(typ, name),
    opts = vim.tbl_extend("force", handler.opts, opts.runner_opts),
    job_factory = JobFactory.new(output_bunfr, opts.hooks, working_dir:get(), opts.env),
    working_dir = working_dir,
    filelib = filelib,
    _handler = handler,
    _output_bufnr = output_bunfr,
  }
  return setmetatable(tbl, Handler), nil
end

function Handler._find(path)
  local registered = M.registered[path]
  if registered then
    return registered, nil
  end

  local handler = modulelib.find("cmdhndlr.handler." .. path)
  if handler then
    return handler, nil
  end

  return nil, "not found handler: " .. path
end

function Handler.__index(self, k)
  return rawget(Handler, k) or self._handler[k]
end

function Handler.result(self, output, err)
  if err ~= nil then
    return nil, err
  end
  return RunnerResult.new(self._output_bufnr, output), nil
end

function M._path(typ, name)
  return ("%s/%s"):format(typ, name:gsub("%.", "/"))
end

function M.register(typ, name, handler)
  M.registered[M._path(typ, name)] = handler
end

return M
