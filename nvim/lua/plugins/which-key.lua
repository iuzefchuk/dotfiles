return {
  "folke/which-key.nvim",
  opts = {
    delay = 0,
    sort = { "desc" },
    icons = {
      group = "",
    },
    spec = {
      { "<leader><tab>", hidden = true },
      { "<leader>c", hidden = true },
      { "<leader>f", hidden = true },
      { "<leader>u", hidden = true },
      { "<leader>w", hidden = true },
      { "<leader>x", hidden = true },
      { "<leader>gh", hidden = true },
      { "<leader>e", desc = "explorer" },
      { "<leader>d", group = false, desc = "docker", icon = { cat = "filetype", name = "dockerfile" } },
      { "<leader>g", group = false, desc = "git" },
      { "<leader>q", group = false, desc = "quit" },
      { "<leader>b", group = "buffer" },
      { "<leader>s", group = false, desc = "search", icon = { icon = "", color = "green" } },
      { "<leader>r", group = false, desc = "replace", icon = { icon = "󰛔", color = "blue" } },
    },
  },
}
