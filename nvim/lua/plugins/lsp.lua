return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      ["*"] = {
        keys = {
          { "<leader>ss", false },
          { "<leader>sS", false },
        },
      },
    },
  },
}
