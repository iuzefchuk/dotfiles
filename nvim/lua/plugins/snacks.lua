local function plain_directories()
  vim.api.nvim_set_hl(0, "SnacksPickerDirectory", {})
end

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("config_plain_directories", { clear = true }),
  callback = function()
    vim.schedule(plain_directories)
  end,
})
vim.schedule(plain_directories)

require("mini.icons").setup()

require("snacks").setup({
  bigfile = { enabled = true },
  quickfile = { enabled = true },
  indent = { enabled = true },
  input = { enabled = true },
  notifier = { enabled = true },
  scope = { enabled = true },
  scroll = { enabled = true },
  statuscolumn = { enabled = true },
  words = { enabled = true },
  explorer = { enabled = true },
  picker = {
    enabled = true,
    sources = {
      explorer = {
        hidden = true,
        layout = {
          hidden = { "input" },
        },
      },
    },
  },
})
