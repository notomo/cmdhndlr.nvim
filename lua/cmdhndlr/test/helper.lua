local plugin_name = vim.split((...):gsub("%.", "/"), "/", true)[1]
local helper = require("vusted.helper")

helper.root = helper.find_plugin_root(plugin_name)
local runtimepath = vim.o.runtimepath

function helper.before_each()
  helper.test_data = require("cmdhndlr.vendor.misclib.test.data_dir").setup(helper.root)
  vim.api.nvim_set_current_dir(helper.test_data.full_path)
  vim.o.runtimepath = runtimepath
  require("cmdhndlr").setup({
    log_file_path = helper.test_data.full_path .. "cmdhndlr.log",
  })
end

function helper.after_each()
  helper.cleanup()
  helper.cleanup_loaded_modules(plugin_name)
  helper.test_data:teardown()
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
local asserters = require(plugin_name .. ".vendor.assertlib").list()
require(plugin_name .. ".vendor.misclib.test.assert").register(asserts.create, asserters)

return helper
