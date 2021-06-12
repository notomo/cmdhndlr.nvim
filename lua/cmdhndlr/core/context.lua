local repository = require("cmdhndlr.lib.repository").Repository.new("context")

local M = {}

local Context = {}
Context.__index = Context
M.Context = Context

function Context.set(bufnr, runner_factory, args)
  vim.validate({
    bufnr = {bufnr, "number"},
    runner_factory = {runner_factory, "function"},
    args = {args, "table", true},
  })
  local tbl = {_bufnr = bufnr, runner_factory = runner_factory, args = args or {}}
  local self = setmetatable(tbl, Context)
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
  repository:delete(self._bufnr)
end

function Context.delete_from(bufnr)
  local ctx, err = Context.get(bufnr)
  if err ~= nil then
    return err
  end
  return ctx:delete()
end

return M
