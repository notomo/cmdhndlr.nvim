local _states = {}

local State = {}
State.__index = State

--- @param full_name string
--- @param bufnr integer
--- @param job table
--- @param runner_factory function
--- @param args table?
--- @param hooks table
function State.set(full_name, bufnr, job, runner_factory, args, hooks, executed_cmd, working_dir_path)
  local tbl = {
    full_name = full_name,
    bufnr = bufnr,
    job = job,
    runner_factory = runner_factory,
    args = args or {},
    hooks = hooks,
    executed_cmd = executed_cmd,
    working_dir_path = working_dir_path,
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

--- @param bufnr integer?
function State.get(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local state = _states[bufnr]
  if not state then
    return "no buffer: " .. bufnr
  end
  return state
end

function State.find_running(current_state, reuse_predicate)
  local state = State._find(current_state.full_name, function(state)
    return state.job:is_running() and reuse_predicate(current_state, state)
  end)
  if type(state) == "string" then
    local err = state
    return "no running runner: " .. err
  end
  return state
end

--- @param full_name string?
--- @param predicate function
function State._find(full_name, predicate)
  if not full_name then
    return State.get()
  end

  for _, state in pairs(_states) do
    if predicate(state) then
      return state
    end
  end
  return "not found: " .. full_name
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
