return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    local disabled = vim.tbl_get(opts, "options", "disabled_filetypes", "statusline")
    if not disabled then
      return
    end
    for i = #disabled, 1, -1 do
      if disabled[i] == "snacks_dashboard" then
        table.remove(disabled, i)
      end
    end
  end,
}
