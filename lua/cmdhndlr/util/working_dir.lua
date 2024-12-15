local M = {}

function M.upward_pattern(...)
  local pattenrs = { ... }
  return function()
    local root = vim.fs.root(".", pattenrs)
    return root or "."
  end
end

function M.upward_marker(...)
  local markers = { ... }
  return function()
    return vim.fs.find(markers, {
      upward = true,
    })[1]
  end
end

return M
