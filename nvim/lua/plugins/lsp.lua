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

vim.diagnostic.config({
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  virtual_text = {
    spacing = 4,
    source = "if_many",
    prefix = "●",
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.HINT] = " ",
      [vim.diagnostic.severity.INFO] = " ",
    },
  },
})

vim.lsp.config("vtsls", {
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
    "vue",
  },
  settings = {
    complete_function_calls = true,
    vtsls = {
      autoUseWorkspaceTsdk = true,
      experimental = { maxInlayHintLength = 30 },
      tsserver = { globalPlugins = { vue_plugin } },
    },
    typescript = ts_settings,
    javascript = ts_settings,
  },
})

vim.lsp.config("jsonls", {
  settings = {
    json = {
      schemas = require("schemastore").json.schemas(),
      format = { enable = true },
      validate = { enable = true },
    },
  },
})

vim.lsp.config("eslint", {
  settings = {
    workingDirectories = { mode = "auto" },
    format = false,
  },
})

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      diagnostics = { disable = { "missing-fields" } },
    },
  },
})

vim.lsp.enable({ "vtsls", "vue_ls", "eslint", "jsonls", "lua_ls" })

local group = vim.api.nvim_create_augroup("config_lsp", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
  group = group,
  callback = function(event)
    if vim.bo[event.buf].filetype ~= "vue" then
      vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
    end

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = true })
    end
  end,
})

vim.api.nvim_create_autocmd("LspDetach", { group = group, callback = reset_stranded_diagnostics })

require("lazydev").setup({
  library = {
    { path = "${3rd}/luv/library", words = { "vim%.uv" } },
    { path = "snacks.nvim", words = { "Snacks" } },
  },
})
