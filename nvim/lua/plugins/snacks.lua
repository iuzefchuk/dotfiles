local cheatsheet = {
  {
    pane = 1,
    title = "Write & Quit",
    commands = {
      { ":w", "write current file" },
      { ":wa", "write all buffers" },
      { ":wq  :x", "write and close" },
      { ":q", "close window" },
      { ":qa", "close everything" },
      { ":q!  :qa!", "discard changes" },
    },
  },
  {
    pane = 1,
    title = "Files & Buffers",
    commands = {
      { ":e {file}", "open file" },
      { ":e!", "reload from disk" },
      { ":sav {file}", "save as" },
      { ":ls", "list buffers" },
      { ":b {n}", "jump to buffer" },
      { ":bd", "close buffer" },
      { ":bn  :bp", "next / prev buffer" },
    },
  },
  {
    pane = 1,
    title = "Windows & Tabs",
    commands = {
      { ":sp", "split below" },
      { ":vs", "split right" },
      { ":clo", "close this window" },
      { ":on", "close all others" },
      { ":tabnew", "new tab" },
      { ":tabn  :tabp", "next / prev tab" },
      { ":tabc", "close tab" },
    },
  },
  {
    pane = 2,
    title = "Search & Replace",
    commands = {
      { ":s/a/b/", "replace on this line" },
      { ":%s/a/b/g", "replace in file" },
      { ":%s/a/b/gc", "replace, confirm each" },
      { ":g/pat/d", "delete matching lines" },
      { ":v/pat/d", "keep only matches" },
      { ":noh", "clear search highlight" },
    },
  },
  {
    pane = 2,
    title = "Grep & Quickfix",
    commands = {
      { ":grep {pat}", "search project" },
      { ":cope", "open results" },
      { ":cn  :cp", "next / prev result" },
      { ":cdo {cmd}", "run cmd on each match" },
      { ":cfdo {cmd}", "run cmd on each file" },
      { ":ccl", "close results" },
      { ":colder  :cnewer", "older / newer results" },
    },
  },
  {
    pane = 2,
    title = "Learn & Misc",
    commands = {
      { ":h {topic}", "open help" },
      { ":h ex-cmd-index", "every command there is" },
      { ":command", "list custom commands" },
      { ":map", "list keymaps" },
      { ":norm {keys}", "run normal-mode keys" },
      { ":!{cmd}", "run shell command" },
      { ":earlier  :later", "undo through time" },
    },
  },
}

local function sections()
  local items = {}
  for _, group in ipairs(cheatsheet) do
    items[#items + 1] = {
      pane = group.pane,
      padding = { 1, 2 },
      text = { { group.title, hl = "title" } },
    }
    for _, entry in ipairs(group.commands) do
      items[#items + 1] = {
        pane = group.pane,
        text = {
          { entry[1], hl = "normal", width = 19 },
          { entry[2], hl = "dir" },
        },
      }
    end
  end
  return items
end

local function plain_directories()
  vim.api.nvim_set_hl(0, "SnacksPickerDirectory", {})
end

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  init = function()
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("config_plain_directories", { clear = true }),
      callback = function()
        vim.schedule(plain_directories)
      end,
    })
    vim.schedule(plain_directories)
  end,
  opts = {
    bigfile = { enabled = true },
    quickfile = { enabled = true },
    indent = { enabled = true },
    input = { enabled = true },
    notifier = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    bufdelete = { enabled = true },
    explorer = { enabled = true },
    lazygit = { enabled = true },
    terminal = { enabled = true },
    dashboard = {
      enabled = true,
      width = 42,
      pane_gap = 6,
      sections = sections(),
    },
    picker = {
      enabled = true,
      sources = {
        explorer = {
          hidden = true,
          layout = {
            hidden = { "input" },
          },
        },
      },
    },
  },
}
