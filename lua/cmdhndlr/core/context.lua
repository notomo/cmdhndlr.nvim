local repository = require("cmdhndlr.lib.repository").Repository.new("context")

local M = {}

local Context = {}
Context.__index = Context
M.Context = Context

function Context.set(path, result, runner_factory, args)
  vim.validate({
    result = {result, "table"},
    runner_factory = {runner_factory, "function"},
    args = {args, "table", true},
  })

  local tbl = {name = path, result = result, runner_factory = runner_factory, args = args or {}}
  local self = setmetatable(tbl, Context)

  local bufnr = result.bufnr
  repository:set(bufnr, self)
  vim.cmd(([[autocmd BufWipeout <buffer=%s> lua require("cmdhndlr.command").Command.new("delete", %s)]]):format(bufnr, bufnr))

  return self
end

function Context.get(bufnr)
  vim.validate({bufnr = {bufnr, "number", true}})
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local ctx = repository:get(bufnr)
  if not ctx then
    return nil, "no context"
  end
  return ctx, nil
end

function Context.delete(self)
  repository:delete(self.result.bufnr)
end

function Context.delete_from(bufnr)
  local ctx, err = Context.get(bufnr)
  if err ~= nil then
    return err
  end
  return ctx:delete()
end

function Context.find(name)
  vim.validate({name = {name, "string", true}})

  if not name then
    return Context.get()
  end

  for _, ctx in repository:all() do
    if ctx.name == name then
      return ctx, nil
    end
  end
  return nil, "no context"
end

return M
