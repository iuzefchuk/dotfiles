local mason_root = vim.env.MASON or (vim.fn.stdpath("data") .. "/mason")

local function pkg(name, path)
  return vim.fs.normalize(mason_root .. "/packages/" .. name .. path)
end

local vue_plugin = {
  name = "@vue/typescript-plugin",
  location = pkg("vue-language-server", "/node_modules/@vue/typescript-plugin"),
  languages = { "vue" },
  configNamespace = "typescript",
  enableForWorkspaceTypeScriptVersions = true,
}

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
        [vim.diagnostic.severity.ERROR] = " ",
        [vim.diagnostic.severity.WARN] = " ",
        [vim.diagnostic.severity.HINT] = " ",
        [vim.diagnostic.severity.INFO] = " ",
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
    before_init = function(_, config)
      config.settings.json.schemas = config.settings.json.schemas or {}
      vim.list_extend(config.settings.json.schemas, require("schemastore").json.schemas())
    end,
    settings = {
      json = {
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
end

return {
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    opts = {
      ensure_installed = {
        "codelldb@v1.12.2",
        "eslint-lsp@4.10.0",
        "json-lsp@4.10.0",
        "lua-language-server@3.18.2",
        "prettier@3.9.5",
        "shfmt@v3.13.1",
        "stylua@v2.5.2",
        "tree-sitter-cli@v0.26.11",
        "vtsls@0.3.0",
        "vue-language-server@3.3.7",
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)
      local Package = require("mason-core.package")
      local registry = require("mason-registry")
      registry.refresh(function()
        for _, spec in ipairs(opts.ensure_installed) do
          local name, version = Package.Parse(spec)
          local ok, p = pcall(registry.get_package, name)
          if ok and not p:is_installed() then
            p:install({ version = version })
          end
        end
      end)
    end,
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
    dependencies = { "mason-org/mason.nvim", "b0o/SchemaStore.nvim" },
    config = setup,
  },

  {
    "mfussenegger/nvim-dap",
    lazy = true,
  },

  {
    "mrcjkb/rustaceanvim",
    version = "^7",
    lazy = false,
  },
}
