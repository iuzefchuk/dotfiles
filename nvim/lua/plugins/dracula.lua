return {
  {
    "dracula/vim",
    name = "dracula",
    init = function()
      local diff = {
        DiffAdd = { fg = "#69FF94", bg = "#2E4940" },
        DiffDelete = { fg = "#FF6E6E", bg = "#48303B" },
        DiffText = { fg = "#FFFFA5", bg = "#4A4630" },
      }

      local function fix()
        if vim.g.colors_name == "dracula" then
          for group, hl in pairs(diff) do
            vim.api.nvim_set_hl(0, group, hl)
          end
        elseif vim.g.colors_name == "alucard" then
          vim.g.terminal_color_0 = "#1F1F1F"

          if vim.o.background ~= "light" then
            vim.o.background = "light"
          end
        end
      end

      vim.api.nvim_create_autocmd("ColorScheme", { pattern = { "dracula", "alucard" }, callback = fix })
      fix()
    end,
  },
}
