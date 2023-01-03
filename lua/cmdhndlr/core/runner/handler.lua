local JobFactory = require("cmdhndlr.core.job_factory")
local WorkingDir = require("cmdhndlr.core.working_dir")
local modulelib = require("cmdhndlr.vendor.misclib.module")
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
  local global = require("cmdhndlr.core.custom").config[typ].default[filetype]
  local buffer_local = (vim.b[opts.bufnr].cmdhndlr or {})[typ]

  local name = opts.name
  if name == "" and buffer_local then
    name = buffer_local
  elseif name == "" and global then
    name = global
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
  local tbl = {
    name = name,
    path = M._path(typ, name),
    working_dir = working_dir,
    _handler = handler,
    _runner_opts = opts.runner_opts,
    _env = opts.env,
  }
  return setmetatable(tbl, Handler), nil
end

function Handler.runner(self, observer)
  local log_file_path = require("cmdhndlr.core.custom").config.log_file_path
  return setmetatable({
    opts = vim.tbl_extend("force", self._handler.opts, self._runner_opts),
    job_factory = JobFactory.new(observer, self.working_dir:get(), self._env, log_file_path),
    working_dir = self.working_dir,
    filelib = filelib,
  }, {
    __index = self._handler,
  })
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

function M._path(typ, name)
  return ("%s/%s"):format(typ, name:gsub("%.", "/"))
end

function M.register(typ, name, handler)
  M.registered[M._path(typ, name)] = handler
end

function M.all()
  local names = {}

  local paths = vim.api.nvim_get_runtime_file("lua/cmdhndlr/handler/**/*.lua", true)
  for _, path in ipairs(paths) do
    local file = vim.split(path, "lua/cmdhndlr/handler/", { plain = true })[2]
    local name = file:sub(1, #file - 4)
    table.insert(names, name)
  end

  for name in pairs(M.registered) do
    table.insert(names, name)
  end

  return names
end

return M
