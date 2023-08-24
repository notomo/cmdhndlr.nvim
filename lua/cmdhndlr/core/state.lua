local _states = {}

local State = {}
State.__index = State

function State.set(path, bufnr, job, runner_factory, args, hooks)
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
  local self = setmetatable(tbl, State)

  _states[bufnr] = self

  vim.api.nvim_create_autocmd({ "BufWipeout" }, {
    buffer = bufnr,
    callback = function()
      _states[bufnr] = nil
    end,
  })

  return self
end

function State.get(bufnr)
  vim.validate({ bufnr = { bufnr, "number", true } })
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local state = _states[bufnr]
  if not state then
    return nil, "no buffer: " .. bufnr
  end
  return state, nil
end

function State.find_running(name)
  local state, err = State._find(name, function(state)
    return state.job:is_running()
  end)
  if err then
    return nil, "no running runner: " .. err
  end
  return state, nil
end

function State._find(name, predicate)
  vim.validate({ name = { name, "string", true }, predicate = { predicate, "function", true } })
  predicate = predicate or function()
    return true
  end

  if not name then
    return State.get()
  end

  for _, state in pairs(_states) do
    if state.name == name and predicate(state) then
      return state, nil
    end
  end
  return nil, "not found: " .. name
end

function State.all()
  local all = {}
  for _, state in pairs(_states) do
    table.insert(all, state)
  end
  table.sort(all, function(a, b)
    return a._at > b._at
  end)
  return all
end

return State
