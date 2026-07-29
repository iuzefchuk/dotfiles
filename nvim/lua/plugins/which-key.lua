local leaders = require("config.leaders")

local spec = {
  { "<leader><tab>", hidden = true },
  { "<leader>c", hidden = true },
  { "<leader>f", hidden = true },
  { "<leader>u", hidden = true },
  { "<leader>x", hidden = true },
  { "<leader>gh", hidden = true },
  { "<leader>b", group = "buffer" },
}

for key, leader in pairs(leaders) do
  table.insert(spec, { "<leader>" .. key, group = false, desc = leader.desc, icon = leader.icon })
end

return {
  "folke/which-key.nvim",
  opts = {
    delay = 0,
    sort = { "desc" },
    icons = {
      group = "",
    },
    spec = spec,
  },
}
