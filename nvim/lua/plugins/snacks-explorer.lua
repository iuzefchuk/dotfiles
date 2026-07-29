local function plain_directories()
  vim.api.nvim_set_hl(0, "SnacksPickerDirectory", {})
end

return {
  "folke/snacks.nvim",
  init = function()
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = function()
        vim.schedule(plain_directories)
      end,
    })
    vim.schedule(plain_directories)
  end,
  opts = {
    picker = {
      sources = {
        explorer = {
          hidden = true,
          layout = {
            hidden = { "input" },
          },
          win = {
            list = {
              keys = {
                ["<leader>/"] = false,
              },
            },
          },
        },
      },
    },
  },
}
