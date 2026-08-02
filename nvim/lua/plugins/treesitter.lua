return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  version = false,
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  cmd = { "TSUpdate", "TSInstall", "TSLog", "TSUninstall" },
  opts = {
    ensure_installed = {
      "bash",
      "css",
      "diff",
      "html",
      "javascript",
      "jsdoc",
      "json",
      "json5",
      "lua",
      "luadoc",
      "markdown",
      "markdown_inline",
      "query",
      "regex",
      "rust",
      "scss",
      "svelte",
      "toml",
      "tsx",
      "typescript",
      "vim",
      "vimdoc",
      "vue",
      "yaml",
    },
  },
  config = function(_, opts)
    local TS = require("nvim-treesitter")
    TS.setup(opts)

    local installed = TS.get_installed("parsers")
    local missing = vim.tbl_filter(function(lang)
      return not vim.tbl_contains(installed, lang)
    end, opts.ensure_installed)
    if #missing > 0 then
      TS.install(missing, { summary = true })
    end

    -- start on a parser we actually have; retries naturally as installs land
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("config_treesitter", { clear = true }),
      callback = function(event)
        if pcall(vim.treesitter.start, event.buf) then
          vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
