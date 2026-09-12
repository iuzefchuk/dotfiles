vim.pack.add({
  { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
  "https://github.com/f-person/auto-dark-mode.nvim",
  "https://github.com/folke/snacks.nvim",
  "https://github.com/nvim-mini/mini.icons",
  "https://github.com/nvim-mini/mini.pairs",
  "https://github.com/windwp/nvim-ts-autotag",
  "https://github.com/stevearc/conform.nvim",
  "https://github.com/b0o/SchemaStore.nvim",
  "https://github.com/folke/lazydev.nvim",
  "https://github.com/neovim/nvim-lspconfig",
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
}, { confirm = false })

for _, module in ipairs({ "colorscheme", "snacks", "editing", "format", "lsp", "treesitter", "ui" }) do
  require("plugins." .. module)
end
