local M = {}

function M.run_file(ctx, path)
  if not vim.fn.filereadable(path) then
    error("not readable: " .. path)
  end

  local cmd
  local exe = "AutoHotkey64.exe"
  if vim.fn.has("win32") == 1 then
    cmd = ([[For /F "tokens=*" %%L in ('""%s" "%s""') do @Echo %%L]]):format(exe, path)
  elseif vim.fn.has("wsl") == 1 then
    cmd = exe .. " /ErrorStdOut " .. path .. " 2>&1 | cat"
  else
    error("not supported os")
  end
  return ctx.job_factory:create(cmd)
end

return M
