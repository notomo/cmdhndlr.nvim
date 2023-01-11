local M = {}

M.opts = {
  use_in_repl = false,
  use_dune_top = false,
}

function M.run_file(self, path)
  if self.opts.use_in_repl then
    local input = ""
    if self.opts.use_dune_top then
      input = [[
#use_output "dune top";;
]]
    end

    input = input .. ([[
#use "%s";;
#quit;;
]]):format(path)
    return self.job_factory:create({ "ocaml" }, { input = input })
  end
  return self.job_factory:create({ "ocaml", path })
end

return M
