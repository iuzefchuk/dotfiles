return {
  {
    "Mofiqul/dracula.nvim",
    opts = {
      overrides = function(colors)
        return {
          DiffAdd = { fg = colors.bright_green, bg = "#2E4940" },
          DiffDelete = { fg = colors.bright_red, bg = "#48303B" },
          DiffText = { fg = colors.bright_yellow, bg = "#4A4630" },
        }
      end,
    },
  },
}
