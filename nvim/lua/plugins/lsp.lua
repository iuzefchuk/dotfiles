local mason_root = vim.env.MASON or (vim.fn.stdpath("data") .. "/mason")

local function pkg(name, path)
  return vim.fs.normalize(mason_root .. "/packages/" .. name .. path)
end

-- vue_ls runs in hybrid mode: it owns the template/style blocks and forwards
-- everything TypeScript to vtsls, which needs the Vue plugin loaded to answer.
-- Vue Language Tools v3 ships the plugin as its own package, so point there.
local vue_plugin = {
  name = "@vue/typescript-plugin",
  location = pkg("vue-language-server", "/node_modules/@vue/typescript-plugin"),
  languages = { "vue" },
  configNamespace = "typescript",
  -- without this the plugin is ignored whenever the project supplies its own
  -- TypeScript, which autoUseWorkspaceTsdk makes the common case
  enableForWorkspaceTypeScriptVersions = true,
}

local svelte_plugin = {
  name = "typescript-svelte-plugin",
  location = pkg("svelte-language-server", "/node_modules/typescript-svelte-plugin"),
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
      "svelte",
    },
    settings = {
      complete_function_calls = true,
      vtsls = {
        autoUseWorkspaceTsdk = true,
        experimental = { maxInlayHintLength = 30 },
        tsserver = { globalPlugins = { vue_plugin, svelte_plugin } },
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

  -- eslint --fix on save, ahead of prettier. `LspEslintFixAll` is created by
  -- lspconfig's own on_attach, so chain onto it rather than replacing it.
  local eslint_on_attach = vim.lsp.config.eslint and vim.lsp.config.eslint.on_attach

  vim.lsp.config("eslint", {
    settings = {
      workingDirectories = { mode = "auto" },
      format = true,
    },
    on_attach = function(client, buf)
      if eslint_on_attach then
        eslint_on_attach(client, buf)
      end
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("eslint_fix_" .. buf, { clear = true }),
        buffer = buf,
        command = "LspEslintFixAll",
      })
    end,
  })

  vim.lsp.enable({ "vtsls", "vue_ls", "svelte", "eslint", "jsonls", "lua_ls" })

  -- inlay hints are noisy in .vue SFCs, where vtsls answers through the plugin
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(event)
      if vim.bo[event.buf].filetype ~= "vue" then
        vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
      end
    end,
  })

  vim.api.nvim_create_autocmd("LspDetach", { callback = reset_stranded_diagnostics })

  vim.api.nvim_create_user_command("EslintRestart", restart_eslint, {
    desc = "Restart eslint to drop stale type-aware diagnostics",
  })
end

return {
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    opts = {
      ensure_installed = {
        "eslint-lsp",
        "json-lsp",
        "lua-language-server",
        "prettier",
        "stylua",
        "svelte-language-server",
        "vtsls",
        "vue-language-server",
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)
      local registry = require("mason-registry")
      registry.refresh(function()
        for _, name in ipairs(opts.ensure_installed) do
          local ok, p = pcall(registry.get_package, name)
          if ok and not p:is_installed() then
            p:install()
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
    "mrcjkb/rustaceanvim",
    version = "^7",
    lazy = false,
    ft = { "rust" },
  },
}
