-- Project root: prefer an attached LSP's workspace, else walk up for a marker.
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

local commands = {
  Close = {
    desc = "close",
    run = function()
      Snacks.bufdelete.all()
    end,
  },
  Docker = {
    desc = "docker",
    run = function()
      Snacks.terminal("lazydocker")
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
  GrugFar = {
    desc = "replace",
    run = function()
      local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
      require("grug-far").open({
        transient = true,
        prefills = { filesFilter = ext and ext ~= "" and "*." .. ext or nil },
      })
    end,
  },
}

-- the typed `:Cmd` lingers on the cmdline until something forces a redraw of it
local function clear_cmdline()
  vim.api.nvim_echo({}, false, {})
end

for name, command in pairs(commands) do
  vim.api.nvim_create_user_command(name, function()
    command.run()
    vim.schedule(clear_cmdline)
  end, { desc = command.desc, range = true })
end
