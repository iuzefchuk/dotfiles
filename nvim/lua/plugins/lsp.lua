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

local function setup()
  local vue_plugin = {
    name = "@vue/typescript-plugin",
    location = vim.fs.joinpath(vim.env.MASON, "packages/vue-language-server/node_modules/@vue/typescript-plugin"),
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

  require("mason-lspconfig").setup({ automatic_enable = { exclude = { "stylua" } } })

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
end

return {
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    opts = {},
  },

  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = {
        { "eslint-lsp", version = "4.10.0" },
        { "json-lsp", version = "4.10.0" },
        { "lua-language-server", version = "3.19.1" },
        { "prettier", version = "3.9.6" },
        { "shfmt", version = "v3.14.1" },
        { "stylua", version = "v2.5.2" },
        { "tree-sitter-cli", version = "v0.27.0" },
        { "vtsls", version = "0.3.0" },
        { "vue-language-server", version = "3.3.11" },
      },
    },
  },

  {
    "mason-org/mason-lspconfig.nvim",
    lazy = true,
    dependencies = { "mason-org/mason.nvim" },
  },

  {
    "b0o/SchemaStore.nvim",
    lazy = true,
    version = false,
  },

  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        { path = "snacks.nvim", words = { "Snacks" } },
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "mason-org/mason.nvim", "mason-org/mason-lspconfig.nvim", "b0o/SchemaStore.nvim" },
    config = setup,
  },
}
