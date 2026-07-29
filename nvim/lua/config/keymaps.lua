local leaders = require("config.leaders")

local prefixes = {
  " ",
  ",",
  "-",
  ".",
  "/",
  ":",
  "?",
  "`",
  "|",
  "<Tab>",
  "E",
  "K",
  "L",
  "S",
  "c",
  "d",
  "f",
  "l",
  "n",
  "s",
  "u",
  "w",
  "x",
}

local keep = {}
for key, leader in pairs(leaders) do
  keep[" " .. key] = true
  if leader.from then
    keep[leader.from] = true
  end
end

local modes = { "n", "v", "x", "s", "o", "i", "t" }

local function removable(lhs)
  if lhs:sub(1, 1) ~= " " or #lhs < 2 or keep[lhs] then
    return false
  end
  local rest = lhs:sub(2)
  for _, prefix in ipairs(prefixes) do
    if rest:sub(1, #prefix) == prefix then
      return true
    end
  end
  return false
end

local function prune(buf)
  for _, mode in ipairs(modes) do
    local maps = buf and vim.api.nvim_buf_get_keymap(buf, mode) or vim.api.nvim_get_keymap(mode)
    for _, map in ipairs(maps) do
      if removable(map.lhs) then
        pcall(vim.keymap.del, mode, map.lhs, buf and { buffer = buf } or nil)
      end
    end
  end
end

local actions = {}

local function capture(map)
  local opts = {
    silent = map.silent == 1,
    nowait = map.nowait == 1,
    expr = map.expr == 1,
    remap = map.noremap == 0,
  }
  if opts.expr then
    opts.replace_keycodes = map.replace_keycodes == 1
  end
  return { rhs = map.callback or map.rhs, opts = opts }
end

local function collapse_to_leaves()
  for _, mode in ipairs(modes) do
    local maps = vim.api.nvim_get_keymap(mode)

    for _, map in ipairs(maps) do
      for key, leader in pairs(leaders) do
        if leader.from == map.lhs then
          actions[key] = actions[key] or {}
          actions[key][map.mode] = actions[key][map.mode] or capture(map)
        end
      end
    end

    for _, map in ipairs(maps) do
      local lhs = map.lhs
      for key in pairs(leaders) do
        if lhs:sub(1, 2) == " " .. key and #lhs > 2 then
          pcall(vim.keymap.del, mode, lhs)
        end
      end
    end
  end

  for key, leader in pairs(leaders) do
    for mode, action in pairs(actions[key] or {}) do
      local opts = vim.tbl_extend("force", action.opts, { desc = leader.desc })
      vim.keymap.set(mode, "<leader>" .. key, action.rhs, opts)
    end
  end
end

local function rebind_explorer()
  vim.keymap.set("n", "<leader>e", function()
    Snacks.explorer({ cwd = LazyVim.root() })
  end, { desc = leaders.e.desc })
end

local function rebind_search()
  vim.keymap.set("n", "<leader>s", function()
    Snacks.picker.grep({ cwd = LazyVim.root() })
  end, { desc = leaders.s.desc })
end

local function rebind_write()
  vim.keymap.set("n", "<leader>w", "<cmd>update<cr>", { desc = leaders.w.desc })
end

prune()
collapse_to_leaves()
rebind_explorer()
rebind_search()
rebind_write()

vim.api.nvim_create_autocmd("User", {
  pattern = { "VeryLazy", "LazyLoad" },
  callback = function()
    prune()
    collapse_to_leaves()
    rebind_explorer()
    rebind_search()
    rebind_write()
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    vim.schedule(function()
      prune(event.buf)
    end)
  end,
})
