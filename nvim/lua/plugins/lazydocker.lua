return {
  "folke/snacks.nvim",
  keys = {
    {
      "<leader>d",
      function()
        Snacks.terminal("lazydocker")
      end,
      desc = "docker",
    },
  },
}
