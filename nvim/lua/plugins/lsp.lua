local function reset_stranded_diagnostics(event)
  for ns, info in pairs(vim.diagnostic.get_namespaces()) do
    local segments = vim.split(info.name or "", ".", { plain = true })
    if segments[1] == "nvim" and segments[2] == "lsp" and tonumber(segments[4]) == event.data.client_id then
      vim.diagnostic.reset(ns, event.buf)
    end
  end
end

local function restart_eslint()
  local clients = vim.lsp.get_clients({ name = "eslint" })
  if #clients == 0 then
    vim.notify("eslint is not attached", vim.log.levels.WARN)
    return
  end
  for _, client in ipairs(clients) do
    client:stop(true)
  end
  local timer = assert(vim.uv.new_timer())
  local waited = 0
  local function enable_once_exited()
    waited = waited + 50
    if #vim.lsp.get_clients({ name = "eslint" }) > 0 and waited < 5000 then
      return
    end
    timer:stop()
    timer:close()
    vim.lsp.enable("eslint")
  end
  timer:start(50, 50, vim.schedule_wrap(enable_once_exited))
end

return {
  "neovim/nvim-lspconfig",
  init = function()
    vim.api.nvim_create_autocmd("LspDetach", { callback = reset_stranded_diagnostics })
    vim.api.nvim_create_user_command("EslintRestart", restart_eslint, {
      desc = "Restart eslint to drop stale type-aware diagnostics",
    })
  end,
}
