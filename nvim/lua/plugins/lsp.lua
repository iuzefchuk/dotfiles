local ts_settings = {
  updateImportsOnFileMove = { enabled = "always" },
  inlayHints = {
    enumMemberValues = { enabled = true },
    functionLikeReturnTypes = { enabled = true },
    parameterNames = { enabled = "literals" },
    parameterTypes = { enabled = true },
    propertyDeclarationTypes = { enabled = true },
    variableTypes = { enabled = false },
  },
}

local function reset_stranded_diagnostics(event)
  for ns, info in pairs(vim.diagnostic.get_namespaces()) do
    local segments = vim.split(info.name or "", ".", { plain = true })
    if segments[1] == "nvim" and segments[2] == "lsp" and tonumber(segments[4]) == event.data.client_id then
      vim.diagnostic.reset(ns, event.buf)
    end
  end
end

local vue_server = vim.fn.exepath("vue-language-server")
local vue_plugin = {
  name = "@vue/typescript-plugin",
  location = vim.fs.dirname(vim.fs.dirname(vim.uv.fs_realpath(vue_server) or vue_server)),
  languages = { "vue" },
  configNamespace = "typescript",
  enableForWorkspaceTypeScriptVersions = true,
}

vim.diagnostic.config({ severity_sort = true, virtual_text = { spacing = 4, source = "if_many", prefix = "●" } })

vim.lsp.config("vtsls", {
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
  settings = {
    vtsls = {
      autoUseWorkspaceTsdk = true,
      experimental = { maxInlayHintLength = 30 },
      tsserver = { globalPlugins = { vue_plugin } },
    },
    typescript = ts_settings,
    javascript = ts_settings,
  },
})

vim.lsp.config("lua_ls", { settings = { Lua = { diagnostics = { globals = { "vim", "Snacks" } } } } })

vim.lsp.enable({ "vtsls", "vue_ls", "eslint", "jsonls", "lua_ls" })

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    if vim.bo[event.buf].filetype ~= "vue" then vim.lsp.inlay_hint.enable(true, { bufnr = event.buf }) end
  end,
})

vim.api.nvim_create_autocmd("LspDetach", { callback = reset_stranded_diagnostics })
