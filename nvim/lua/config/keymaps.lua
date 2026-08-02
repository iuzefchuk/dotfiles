local commands = require("config.commands")

local modes = { "n", "v", "x", "s", "o", "i", "t" }

local actions = {}

local function capture(map)
  return { rhs = map.callback or map.rhs, remap = map.noremap == 0 }
end

-- lazy.nvim binds unloaded `keys` specs to a stub that loads the plugin and then
-- replays the original lhs. Capturing one would replay a leader sequence that no
-- longer exists, leaving the keys to run as literal normal-mode commands.
local function stub(rhs)
  if type(rhs) ~= "function" then
    return false
  end
  local info = debug.getinfo(rhs, "S")
  return info ~= nil and info.source:find("lazy/core/handler/keys", 1, true) ~= nil
end

local function collect()
  for _, mode in ipairs(modes) do
    for _, map in ipairs(vim.api.nvim_get_keymap(mode)) do
      for name, command in pairs(commands) do
        if command.from == map.lhs and not stub(map.callback) then
          actions[name] = actions[name] or capture(map)
        end
      end
    end
  end
end

-- the buffer can be wiped between the autocmd firing and the scheduled prune
local function prune(buf)
  if buf and not vim.api.nvim_buf_is_valid(buf) then
    return
  end

  for _, mode in ipairs(modes) do
    local maps = buf and vim.api.nvim_buf_get_keymap(buf, mode) or vim.api.nvim_get_keymap(mode)
    for _, map in ipairs(maps) do
      if map.lhs:sub(1, 1) == " " and #map.lhs > 1 then
        pcall(vim.keymap.del, mode, map.lhs, buf and { buffer = buf } or nil)
      end
    end
  end
end

local function run(name)
  local command = commands[name]
  if command.run then
    return command.run()
  end

  local action = actions[name]
  if not action then
    return vim.notify((":%s is not bound"):format(name), vim.log.levels.WARN)
  end
  if type(action.rhs) == "function" then
    return action.rhs()
  end

  local keys = vim.api.nvim_replace_termcodes(action.rhs, true, false, true)
  vim.api.nvim_feedkeys(keys, action.remap and "m" or "n", false)
end

collect()
prune()

-- the typed `:Cmd` lingers on the cmdline until something forces a redraw of it
local function clear_cmdline()
  vim.api.nvim_echo({}, false, {})
end

for name, command in pairs(commands) do
  vim.api.nvim_create_user_command(name, function()
    run(name)
    vim.schedule(clear_cmdline)
  end, { desc = command.desc, range = true })
end

vim.api.nvim_create_autocmd("User", {
  pattern = { "VeryLazy", "LazyLoad" },
  callback = function()
    collect()
    prune()
  end,
})

vim.api.nvim_create_autocmd({ "LspAttach", "BufEnter" }, {
  callback = function(event)
    vim.schedule(function()
      prune(event.buf)
    end)
  end,
})
