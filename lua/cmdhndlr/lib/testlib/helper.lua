local plugin_name = vim.split((...):gsub("%.", "/"), "/", true)[1]
local M = require("vusted.helper")

M.root = M.find_plugin_root(plugin_name)
local runtimepath = vim.o.runtimepath

function M.before_each()
  vim.cmd("filetype on")
  vim.cmd("syntax enable")
  M.test_data_path = "spec/test_data/" .. math.random(1, 2 ^ 30) .. "/"
  M.test_data_dir = M.root .. "/" .. M.test_data_path
  M.new_directory("")
  vim.api.nvim_set_current_dir(M.test_data_dir)
  vim.o.runtimepath = runtimepath
end

function M.after_each()
  vim.cmd("tabedit")
  vim.cmd("tabonly!")
  vim.cmd("silent %bwipeout!")
  vim.cmd("filetype off")
  vim.cmd("syntax off")
  M.cleanup_loaded_modules(plugin_name)
  vim.fn.delete(M.root .. "/spec/test_data", "rf")
  vim.cmd("messages clear")
  print(" ")
end

function M.use_parsers()
  vim.o.runtimepath = M.root .. "/script/nvim-treesitter," .. vim.o.runtimepath
end

function M.set_lines(lines)
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(lines, "\n"))
end

function M.search(pattern)
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

function M.register_normal_runner(name, handler)
  require("cmdhndlr.core.handler").register("normal_runner", name, handler)
end

function M.register_test_runner(name, handler)
  require("cmdhndlr.core.handler").register("test_runner", name, handler)
end

function M.register_build_runner(name, handler)
  require("cmdhndlr.core.handler").register("build_runner", name, handler)
end

function M.wait(job)
  job:wait(1000)
  -- wait for terminal output
  return vim.wait(1000, function()
    return vim.fn.search("Process exited") ~= 0
  end, 10)
end

function M.new_file(path, ...)
  local f = io.open(M.test_data_dir .. path, "w")
  for _, line in ipairs({...}) do
    f:write(line .. "\n")
  end
  f:close()
end

function M.new_directory(path)
  vim.fn.mkdir(M.test_data_dir .. path, "p")
end

function M.cd(path)
  vim.api.nvim_set_current_dir(M.test_data_dir .. path)
end

local asserts = require("vusted.assert").asserts

asserts.create("tab_count"):register_eq(function()
  return vim.fn.tabpagenr("$")
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

return M
