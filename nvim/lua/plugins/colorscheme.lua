vim.api.nvim_create_autocmd("ColorScheme", {
  callback = vim.schedule_wrap(function() vim.api.nvim_set_hl(0, "SnacksPickerDirectory", {}) end),
})

vim.cmd.colorscheme("catppuccin")

require("auto-dark-mode").setup({ update_interval = 15000 })
