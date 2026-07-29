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
  "<tab>",
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

local keep = {
  [" d"] = true,
  [" s"] = true,
  [" sg"] = true,
  [" sr"] = true,
}

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

local leaves = {
  { key = "g", from = " gg", desc = "git" },
  { key = "q", from = " qq", desc = "quit" },
  { key = "s", from = " sg", desc = "search" },
  { key = "r", from = " sr", desc = "replace" },
}

local actions = {}

local function collapse_to_leaves()
  for _, leaf in ipairs(leaves) do
    for _, mode in ipairs(modes) do
      for _, map in ipairs(vim.api.nvim_get_keymap(mode)) do
        if map.lhs == leaf.from then
          actions[leaf.key] = actions[leaf.key] or {}
          actions[leaf.key][map.mode] = actions[leaf.key][map.mode] or map.callback or map.rhs
        end
      end
    end
  end

  for _, mode in ipairs(modes) do
    for _, map in ipairs(vim.api.nvim_get_keymap(mode)) do
      local lhs = map.lhs
      for _, leaf in ipairs(leaves) do
        if lhs:sub(1, 2) == " " .. leaf.key and #lhs > 2 then
          pcall(vim.keymap.del, mode, lhs)
        end
      end
    end
  end

  for _, leaf in ipairs(leaves) do
    for mode, action in pairs(actions[leaf.key] or {}) do
      vim.keymap.set(mode, "<leader>" .. leaf.key, action, { desc = leaf.desc })
    end
  end
end

local function rebind_explorer()
  vim.keymap.set("n", "<leader>e", function()
    Snacks.explorer({ cwd = LazyVim.root() })
  end, { desc = "explorer" })
end

prune()
collapse_to_leaves()
rebind_explorer()

vim.api.nvim_create_autocmd("User", {
  pattern = { "VeryLazy", "LazyLoad" },
  callback = function()
    prune()
    collapse_to_leaves()
    rebind_explorer()
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    vim.schedule(function()
      prune(event.buf)
    end)
  end,
})
