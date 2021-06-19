local JobFactory = require("cmdhndlr.core.job_factory").JobFactory
local WorkingDir = require("cmdhndlr.core.working_dir").WorkingDir
local RunnerResult = require("cmdhndlr.core.runner_result").RunnerResult
local modulelib = require("cmdhndlr.lib.module")
local filelib = require("cmdhndlr.lib.file")

local M = {}

M.registered = {}

local Handler = {registered = {}}
M.Handler = Handler

function Handler.new(typ, bufnr, name, hooks, raw_working_dir, opts)
  vim.validate({
    type = {typ, "string"},
    bufnr = {bufnr, "number"},
    name = {name, "string", true},
    hooks = {hooks, "table"},
    working_dir = {raw_working_dir, "function", true},
    opts = {opts, "table", true},
  })

  local filetype = vim.bo[bufnr].filetype
  local default = require("cmdhndlr.core.custom").config[typ].default[filetype]
  if not name and default ~= nil then
    name = default
  end
  if not name then
    return nil, "no handler"
  end

  local path = M._path(typ, name)
  local handler, err = Handler._find(path)
  if err then
    return nil, err
  end

  local working_dir = WorkingDir.new(raw_working_dir or handler.working_dir, handler.working_dir_marker)
  local output_bunfr = vim.api.nvim_create_buf(false, true)
  local tbl = {
    name = name,
    path = M._path(typ, name),
    opts = vim.tbl_extend("force", handler.opts or {}, opts or {}),
    job_factory = JobFactory.new(output_bunfr, hooks, working_dir:get()),
    working_dir = working_dir,
    filelib = filelib,
    _handler = handler,
    _hooks = hooks,
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

function Handler.result(self, info_factory, output, err)
  local info = info_factory()
  if err ~= nil then
    if type(err) == "table" then
      return nil, err.msg
    end
    return RunnerResult.error(self._output_bufnr, self._hooks, info, err), nil
  end
  return RunnerResult.ok(self._output_bufnr, self._hooks, info, output), nil
end

function Handler.info_factory(self)
  return self._hooks:info_factory()
end

function M._path(typ, name)
  return ("%s/%s"):format(typ, name:gsub("%.", "/"))
end

function M.register(typ, name, handler)
  M.registered[M._path(typ, name)] = handler
end

return M
