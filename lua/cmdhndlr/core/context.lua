local repository = require("cmdhndlr.lib.repository").Repository.new("context")

local M = {}

local Context = {}
Context.__index = Context
M.Context = Context

function Context.set(path, result, runner_factory, args)
  vim.validate({
    result = { result, "table" },
    runner_factory = { runner_factory, "function" },
    args = { args, "table", true },
  })

  local bufnr = result.bufnr
  local tbl = {
    name = path,
    bufnr = bufnr,
    result = result,
    runner_factory = runner_factory,
    args = args or {},
    _at = vim.fn.reltimestr(vim.fn.reltime()),
  }
  local self = setmetatable(tbl, Context)

  repository:set(bufnr, self)
  vim.api.nvim_create_autocmd({ "BufWipeout" }, {
    buffer = bufnr,
    callback = function()
      repository:delete(bufnr)
    end,
  })

  return self
end

function Context.get(bufnr)
  vim.validate({ bufnr = { bufnr, "number", true } })
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local ctx = repository:get(bufnr)
  if not ctx then
    return nil, "no cmdhndlr buffer: " .. bufnr
  end
  return ctx, nil
end

function Context.find(name, predicate)
  vim.validate({ name = { name, "string", true }, predicate = { predicate, "function", true } })
  predicate = predicate or function()
    return true
  end

  if not name then
    return Context.get()
  end

  for _, ctx in repository:all() do
    if ctx.name == name and predicate(ctx) then
      return ctx, nil
    end
  end
  return nil, "no context"
end

function Context.all()
  local all = {}
  for _, ctx in repository:all() do
    table.insert(all, ctx)
  end
  table.sort(all, function(a, b)
    return a._at > b._at
  end)
  return all
end

return M
