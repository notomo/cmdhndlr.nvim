local plugin_name = vim.split((...):gsub("%.", "/"), "/", true)[1]
local helper = require("vusted.helper")

helper.root = helper.find_plugin_root(plugin_name)
local runtimepath = vim.o.runtimepath

function helper.before_each()
  vim.cmd("filetype on")
  vim.cmd("syntax enable")
  helper.test_data = require("cmdhndlr.vendor.misclib.test.data_dir").setup(helper.root)
  vim.api.nvim_set_current_dir(helper.test_data.full_path)
  vim.o.runtimepath = runtimepath
end

function helper.after_each()
  vim.cmd("silent %bwipeout!")
  vim.cmd("filetype off")
  vim.cmd("syntax off")
  helper.cleanup_loaded_modules(plugin_name)
  helper.test_data:teardown()
  vim.cmd("messages clear")
  print(" ")
end

function helper.set_lines(lines)
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(lines, "\n"))
end

function helper.search(pattern)
  local result = vim.fn.search(pattern)
  if result == 0 then
    local info = debug.getinfo(2)
    local pos = ("%s:%d"):format(info.source, info.currentline)
    local lines = table.concat(vim.fn.getbufline("%", 1, "$"), "\n")
    local msg = ("on %s: `%s` not found in buffer:\n%s"):format(pos, pattern, lines)
    assert(false, msg)
  end
  return result
end

function helper.register_normal_runner(name, handler)
  require("cmdhndlr.core.runner.handler").register("normal_runner", name, handler)
end

function helper.register_test_runner(name, handler)
  require("cmdhndlr.core.runner.handler").register("test_runner", name, handler)
end

function helper.register_build_runner(name, handler)
  require("cmdhndlr.core.runner.handler").register("build_runner", name, handler)
end

function helper.on_finished()
  local finished = false
  return setmetatable({
    wait = function()
      local ok = vim.wait(1000, function()
        return finished
      end, 10, false)
      if not ok then
        error("wait timeout")
      end
    end,
  }, {
    __call = function()
      finished = true
    end,
  })
end

function helper.wait(promise)
  local on_finished = helper.on_finished()
  promise:finally(function()
    on_finished()
  end)
  on_finished:wait()
end

local asserts = require("vusted.assert").asserts

asserts.create("tab_count"):register_eq(function()
  return vim.fn.tabpagenr("$")
end)

asserts.create("window_count"):register_eq(function()
  return vim.fn.tabpagewinnr(vim.fn.tabpagenr(), "$")
end)

asserts.create("current_line"):register_eq(function()
  return vim.api.nvim_get_current_line()
end)

asserts.create("exists_message"):register(function(self)
  return function(_, args)
    local expected = args[1]
    self:set_positive(("`%s` not found message"):format(expected))
    self:set_negative(("`%s` found message"):format(expected))
    local messages = vim.split(vim.api.nvim_exec("messages", true), "\n")
    for _, msg in ipairs(messages) do
      if msg:match(expected) then
        return true
      end
    end
    return false
  end
end)

asserts.create("exists_pattern"):register(function(self)
  return function(_, args)
    local pattern = args[1]
    pattern = pattern:gsub("\n", "\\n")
    local result = vim.fn.search(pattern, "n")
    self:set_positive(("`%s` not found"):format(pattern))
    self:set_negative(("`%s` found"):format(pattern))
    return result ~= 0
  end
end)

return helper
