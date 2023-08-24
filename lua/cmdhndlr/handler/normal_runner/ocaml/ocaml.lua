local M = {}

M.opts = {
  use_in_repl = false,
  use_dune_top = false,
}

function M.run_file(ctx, path)
  if ctx.opts.use_in_repl then
    local input = ""
    if ctx.opts.use_dune_top then
      input = [[
#use_output "dune top";;
]]
    end

    input = input .. ([[
#use "%s";;
#quit;;
]]):format(path)
    return ctx.job_factory:create({ "ocaml" }, { input = input })
  end
  return ctx.job_factory:create({ "ocaml", path })
end

return M
