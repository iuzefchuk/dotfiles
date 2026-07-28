local schemes = { dark = "dracula", light = "github_light" }

local function apply(appearance)
  local scheme = schemes[appearance]
  if scheme and vim.g.colors_name ~= scheme then
    vim.cmd.colorscheme(scheme)
  end
end

local function current_appearance()
  if vim.fn.has("mac") == 0 then
    return "dark"
  end
  local out = vim.fn.system({ "defaults", "read", "-g", "AppleInterfaceStyle" })
  return vim.trim(out) == "Dark" and "dark" or "light"
end

return {
  {
    "projekt0n/github-nvim-theme",
    main = "github-theme",
    lazy = false,
    priority = 1000,
    opts = {},
  },

  {
    "f-person/auto-dark-mode.nvim",
    event = "VeryLazy",
    opts = {
      update_interval = 3000,
      fallback = "dark",
      set_dark_mode = function()
        apply("dark")
      end,
      set_light_mode = function()
        apply("light")
      end,
    },
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        apply(current_appearance())
      end,
    },
  },

  { "folke/tokyonight.nvim", enabled = false },
  { "catppuccin/nvim", enabled = false },
}
