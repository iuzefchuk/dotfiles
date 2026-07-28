-- Follow the macOS system appearance: dracula when dark, GitHub Light when light.
-- Owns *which* colorscheme is active; per-theme tweaks live in the theme's own file.

local schemes = { dark = "dracula", light = "github_light" }

local function apply(appearance)
  local scheme = schemes[appearance]
  if scheme and vim.g.colors_name ~= scheme then
    vim.cmd.colorscheme(scheme)
  end
end

-- Synchronous probe, used only to pick the *first* colorscheme at startup.
-- auto-dark-mode syncs on startup too, but via vim.system + vim.schedule, so its
-- answer lands after startup has finished and the wrong theme flashes for a frame.
-- ~5ms, and the value is exactly what the plugin's own poll would return.
local function current_appearance()
  if vim.fn.has("mac") == 0 then
    return "dark"
  end
  local out = vim.fn.system({ "defaults", "read", "-g", "AppleInterfaceStyle" })
  -- The key is absent (and `defaults` exits non-zero) in light mode.
  return vim.trim(out) == "Dark" and "dark" or "light"
end

return {
  {
    "projekt0n/github-nvim-theme",
    main = "github-theme", -- module name doesn't match the repo name
    lazy = false,
    priority = 1000,
    opts = {},
  },

  {
    "f-person/auto-dark-mode.nvim",
    event = "VeryLazy",
    opts = {
      -- macOS has no change signal to subscribe to, so this polls
      -- `defaults read -g AppleInterfaceStyle` on a timer.
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
      -- LazyVim accepts a function here, which lets startup match the system
      -- appearance instead of hardcoding one side and correcting it afterwards.
      colorscheme = function()
        apply(current_appearance())
      end,
    },
  },

  -- Themes bundled with LazyVim that we don't use. LazyVim declares them
  -- `lazy = true`, which only defers loading -- they'd still be cloned to disk
  -- and pinned in lazy-lock.json without this.
  { "folke/tokyonight.nvim", enabled = false },
  { "catppuccin/nvim", enabled = false },
}
