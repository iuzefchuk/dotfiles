return {
  {
    "folke/snacks.nvim",
    keys = {
      -- LazyVim has no default branch picker; <leader>gr is free unless the Octo
      -- extra is enabled, which binds it to "List Repos".
      { "<leader>gr", function() Snacks.picker.git_branches() end, desc = "Git Branches" },
    },
  },
}
