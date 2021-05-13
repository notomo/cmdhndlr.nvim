local JobFactory = require("cmdhndlr.core.job_factory").JobFactory
local WorkingDir = require("cmdhndlr.core.working_dir").WorkingDir
local modulelib = require("cmdhndlr.lib.module")
local filelib = require("cmdhndlr.lib.file")

local M = {}

M.registered = {}

local Handler = {registered = {}}
M.Handler = Handler
Handler.handler_type = "not_implemented"

function Handler.new(typ, name, raw_working_dir, opts)
  vim.validate({
    type = {typ, "string"},
    name = {name, "string"},
    working_dir = {raw_working_dir, "function", true},
    opts = {opts, "table", true},
  })

  local handler, err = Handler._find(typ, name)
  if err then
    return nil, err
  end

  local working_dir = WorkingDir.new(raw_working_dir or handler.working_dir, handler.working_dir_marker)
  local tbl = {
    name = name,
    opts = vim.tbl_extend("force", handler.opts or {}, opts or {}),
    job_factory = JobFactory.new(working_dir:get()),
    working_dir = working_dir,
    filelib = filelib,
    _handler = handler,
  }
  return setmetatable(tbl, Handler)
end

function Handler._find(typ, name)
  local path = M.path(typ, name)

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

function Handler.dispatch(Class, bufnr, name, ...)
  if name ~= nil then
    return Class.new(bufnr, name, ...)
  end

  local filetype = vim.bo[bufnr].filetype
  local default = require("cmdhndlr.core.custom").config[Class.handler_type].default[filetype]
  if default ~= nil then
    return Class.new(bufnr, default, ...)
  end

  return nil, "no handler"
end

function M.path(typ, name)
  return ("%s/%s"):format(typ, name:gsub("%.", "/"))
end

function M.register(typ, name, handler)
  M.registered[M.path(typ, name)] = handler
end

return M
