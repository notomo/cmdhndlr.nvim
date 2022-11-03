local _contexts = {}

local Context = {}
Context.__index = Context

function Context.set(path, bufnr, job, runner_factory, args, hooks)
  vim.validate({
    job = { job, "table" },
    bufnr = { bufnr, "number" },
    runner_factory = { runner_factory, "function" },
    args = { args, "table", true },
    hooks = { hooks, "table" },
  })

  local tbl = {
    name = path,
    bufnr = bufnr,
    job = job,
    runner_factory = runner_factory,
    args = args or {},
    hooks = hooks,
    _at = vim.fn.reltimestr(vim.fn.reltime()),
  }
  local self = setmetatable(tbl, Context)

  _contexts[bufnr] = self

  vim.api.nvim_create_autocmd({ "BufWipeout" }, {
    buffer = bufnr,
    callback = function()
      _contexts[bufnr] = nil
    end,
  })

  return self
end

function Context.get(bufnr)
  vim.validate({ bufnr = { bufnr, "number", true } })
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local ctx = _contexts[bufnr]
  if not ctx then
    return nil, "no buffer: " .. bufnr
  end
  return ctx, nil
end

function Context.find_running(name)
  local ctx, err = Context._find(name, function(ctx)
    return ctx.job:is_running()
  end)
  if err then
    return nil, "no running runner: " .. err
  end
  return ctx, nil
end

function Context._find(name, predicate)
  vim.validate({ name = { name, "string", true }, predicate = { predicate, "function", true } })
  predicate = predicate or function()
    return true
  end

  if not name then
    return Context.get()
  end

  for _, ctx in pairs(_contexts) do
    if ctx.name == name and predicate(ctx) then
      return ctx, nil
    end
  end
  return nil, "not found: " .. name
end

function Context.all()
  local all = {}
  for _, ctx in pairs(_contexts) do
    table.insert(all, ctx)
  end
  table.sort(all, function(a, b)
    return a._at > b._at
  end)
  return all
end

return Context
