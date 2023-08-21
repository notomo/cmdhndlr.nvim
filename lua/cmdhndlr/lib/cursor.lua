local M = {}

function M.store_positions(bufnr)
  local window_ids = vim.fn.win_findbuf(bufnr)

  local views = vim.iter(window_ids):map(function(window_id)
    local view = vim.api.nvim_win_call(window_id, function()
      return vim.fn.winsaveview()
    end)
    return {
      window_id = window_id,
      view = view,
    }
  end)

  return function()
    views:each(function(e)
      vim.api.nvim_win_call(e.window_id, function()
        vim.fn.winrestview(e.view)
      end)
    end)
  end
end

return M
