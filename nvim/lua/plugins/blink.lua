return {
  "saghen/blink.cmp",
  optional = true,
  opts = {
    completion = {
      menu = { auto_show = false }, -- no auto-popup; Ctrl+Space shows it on demand
      ghost_text = { enabled = false }, -- no inline grey suggestion (LazyVim turns this on via vim.g.ai_cmp)
      trigger = {
        show_on_keyword = false, -- don't start completing just because you typed a word character
        show_on_trigger_character = false, -- ...or a trigger character like `.`
      },
    },
  },
}
