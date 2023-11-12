local WorkingDir = require("cmdhndlr.core.working_dir")
local modulelib = require("cmdhndlr.vendor.misclib.module")

local Handler = {}

Handler.registered = {}

function Handler.new(typ, opts)
  vim.validate({
    type = { typ, "string" },
    opts = { opts, "table" },
  })
  local full_name = Handler._full_name(typ, opts.name)
  return Handler.from_full_name(full_name, opts)
end

function Handler.from_full_name(full_name, opts)
  local handler, err = Handler._find(full_name)
  if err then
    return nil, err
  end

  handler.full_name = full_name
  handler.opts = handler.opts or {}

  handler.working_dir = handler.working_dir or function()
    return nil
  end
  handler.working_dir_marker = handler.working_dir_marker or function()
    return nil
  end
  handler.decided_working_dir = WorkingDir.new(
    opts.working_dir() or handler.working_dir(),
    opts.working_dir_marker() or handler.working_dir_marker()
  )

  return handler
end

function Handler._find(full_name)
  local registered = Handler.registered[full_name]
  if registered then
    return registered, nil
  end

  local handler = modulelib.find("cmdhndlr.handler." .. full_name)
  if handler then
    return handler, nil
  end

  return nil, "not found handler: " .. full_name
end

function Handler._full_name(typ, name)
  return ("%s/%s"):format(typ, name:gsub("%.", "/"))
end

function Handler.register(typ, name, handler)
  Handler.registered[Handler._full_name(typ, name)] = handler
end

function Handler.all()
  local items = {}

  local paths = vim.api.nvim_get_runtime_file("lua/cmdhndlr/handler/**/*.lua", true)
  for _, path in ipairs(paths) do
    local file = vim.split(path, "lua/cmdhndlr/handler/", { plain = true })[2]
    local full_name = file:sub(1, #file - 4)
    table.insert(items, {
      full_name = full_name,
      path = path,
    })
  end

  for full_name in pairs(Handler.registered) do
    table.insert(items, {
      full_name = full_name,
    })
  end

  return items
end

return Handler
