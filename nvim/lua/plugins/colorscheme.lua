local themed_terminals = { lazygit = true }

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
  group = vim.api.nvim_create_augroup("config_stale_terminals", { clear = true }),
  callback = function()
    vim.schedule(drop_stale_terminals)
  end,
})

return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1100,
    config = function()
      require("catppuccin").setup()
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  {
    "f-person/auto-dark-mode.nvim",
    lazy = false,
    opts = { update_interval = 15000 },
  },
}
