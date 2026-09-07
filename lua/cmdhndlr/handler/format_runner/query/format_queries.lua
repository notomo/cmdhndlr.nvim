local M = {}

function M.format(ctx, path, stdout_collector)
  local nvim_treesitter = vim.iter(vim.opt.runtimepath:get()):find(function(x)
    return vim.endswith(vim.fs.normalize(x), "/nvim-treesitter")
  end)
  if not nvim_treesitter then
    error("no nivm-treesitter in runtimepath", 0)
  end

  local result_ctx = ctx.job_factory:create({
    "nvim",
    "-l",
    vim.fs.joinpath(nvim_treesitter, "scripts/format-queries.lua"),
    path,
  }, {
    on_stdout = stdout_collector,
    as_job = true,
  })
  result_ctx.reload = true
  return result_ctx
end

return M
