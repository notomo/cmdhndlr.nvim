local M = {}

function M.format(ctx, path, stdout_collector)
  local nvim_treesitter = vim.iter(vim.opt.runtimepath:get()):find(function(x)
    return vim.endswith(vim.fs.normalize(x), "/nvim-treesitter")
  end)
  if not nvim_treesitter then
    return require("cmdhndlr.vendor.promise").reject("no nivm-treesitter in runtimepath")
  end

  return ctx.job_factory
    :create({
      "nvim",
      "-l",
      vim.fs.joinpath(nvim_treesitter, "scripts/format-queries.lua"),
      path,
    }, {
      on_stdout = stdout_collector,
      as_job = true,
    })
    :next(function(result_ctx)
      result_ctx.reload = true
      return result_ctx
    end)
end

return M
