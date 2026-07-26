return {
  {
    "Mofiqul/dracula.nvim",
    opts = {
      overrides = function(colors)
        return {
          -- dracula ships DiffAdd/DiffDelete as full-saturation backgrounds, which
          -- treesitter syntax colors are unreadable on (snacks git diff preview).
          -- Use dark tinted backgrounds instead and keep the accent on the fg.
          DiffAdd = { fg = colors.bright_green, bg = "#2E4940" },
          DiffDelete = { fg = colors.bright_red, bg = "#48303B" },
          DiffText = { fg = colors.bright_yellow, bg = "#4A4630" },
        }
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "dracula",
    },
  },

  -- themes bundled with LazyVim that we don't use
  { "folke/tokyonight.nvim", enabled = false },
  { "catppuccin/nvim", enabled = false },
}
