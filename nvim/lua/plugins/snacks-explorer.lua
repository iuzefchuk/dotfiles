return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        explorer = {
          hidden = true, -- show dotfiles (gitignored files stay hidden)
          win = {
            list = {
              keys = {
                -- Single click opens a file / toggles a directory. By default the
                -- explorer only moves the cursor on click and needs <cr> to open.
                ["<LeftRelease>"] = "confirm",
              },
            },
          },
        },
      },
    },
  },
}
