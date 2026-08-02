local schemes = { dark = "catppuccin-mocha", light = "catppuccin-latte" }

local themed_terminals = { lazygit = true, lazydocker = true }

local function drop_stale_terminals()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local ok, term = pcall(function()
      return vim.b[buf].snacks_terminal
    end)
    local cmd = ok and term and term.cmd
    cmd = type(cmd) == "table" and cmd[1] or cmd
    if cmd and themed_terminals[cmd] and #vim.fn.win_findbuf(buf) == 0 then
      pcall(vim.api.nvim_buf_delete, buf, { force = true })
    end
  end
end

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    vim.schedule(drop_stale_terminals)
  end,
})

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
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1100,
    opts = {
      integrations = {
        blink_cmp = false,
        grug_far = true,
        lsp_trouble = false,
        mason = true,
        mini = true,
        snacks = true,
        treesitter = true,
        which_key = false,
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      apply(current_appearance())
    end,
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
}
