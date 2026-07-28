return {
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader>gr", function() Snacks.picker.git_branches() end, desc = "Git Branches" },
    },
  },
}
