local function root()
  local buf = vim.api.nvim_get_current_buf()

  for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
    for _, ws in ipairs(client.workspace_folders or {}) do
      return vim.uri_to_fname(ws.uri)
    end
    if client.root_dir then
      return client.root_dir
    end
  end

  return vim.fs.root(buf, { ".git", "lua", "package.json" }) or vim.uv.cwd()
end

local function explorer_open()
  return #Snacks.picker.get({ source = "explorer" }) > 0
end

local function close_extra_windows()
  local kept
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local floating = vim.api.nvim_win_get_config(win).relative ~= ""
    local sidebar = vim.bo[buf].filetype:match("^snacks_")
    if not floating and not sidebar then
      if kept then
        pcall(vim.api.nvim_win_close, win, false)
      else
        kept = win
      end
    end
  end
end

local commands = {
  Clear = {
    desc = "reset",
    run = function()
      vim.cmd("silent! tabonly")
      close_extra_windows()
      Snacks.bufdelete.all()
      vim.schedule(function()
        if not explorer_open() then
          Snacks.explorer()
        end
      end)
    end,
  },
  Explore = {
    desc = "explorer",
    run = function()
      Snacks.explorer({ cwd = root() })
    end,
  },
  Git = {
    desc = "git",
    run = function()
      Snacks.lazygit({ cwd = vim.fs.root(0, ".git") or root() })
    end,
  },
  Grep = {
    desc = "search",
    run = function()
      Snacks.picker.grep({ cwd = root() })
    end,
  },
}

local function clear_cmdline()
  vim.api.nvim_echo({}, false, {})
end

for name, command in pairs(commands) do
  vim.api.nvim_create_user_command(name, function()
    command.run()
    vim.schedule(clear_cmdline)
  end, { desc = command.desc, range = true })
end
