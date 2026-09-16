vim.api.nvim_create_autocmd("ColorScheme", {
  callback = vim.schedule_wrap(function()
    local dark = vim.o.background == "dark"
    local text, bar = dark and "#000000" or "#ffffff", dark and "#ffffff" or "#000000"
    local palette = require("catppuccin.palettes").get_palette(dark and "latte" or "mocha")
    vim.api.nvim_set_hl(0, "MsgArea", { fg = text, bg = bar })
    vim.api.nvim_set_hl(0, "ModeMsg", { fg = text, bold = true })
    vim.api.nvim_set_hl(0, "MoreMsg", { fg = palette.blue })
    vim.api.nvim_set_hl(0, "Question", { fg = palette.blue })
    vim.api.nvim_set_hl(0, "WarningMsg", { fg = palette.peach })
    vim.api.nvim_set_hl(0, "ErrorMsg", { fg = palette.red, bold = true, italic = true })
    vim.api.nvim_set_hl(0, "SnacksPickerDirectory", {})
  end),
})

vim.cmd.colorscheme("catppuccin")
