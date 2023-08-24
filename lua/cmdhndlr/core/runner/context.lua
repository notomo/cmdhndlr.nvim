local JobFactory = require("cmdhndlr.core.job_factory")

local Context = {}

function Context.new(handler, global_opts, observer)
  local build_cmd_ctx = {
    bufnr = global_opts.bufnr,
  }
  local tbl = {
    opts = vim.tbl_extend("force", handler.opts, global_opts.runner_opts),
    job_factory = JobFactory.new(
      observer,
      handler.decided_working_dir:get(),
      global_opts.env,
      require("cmdhndlr.core.custom").config.log_file_path,
      global_opts.build_cmd,
      build_cmd_ctx
    ),
    working_dir = handler.decided_working_dir,
  }
  return tbl
end

return Context
