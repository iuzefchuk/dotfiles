local function close_extra_windows()
  local kept
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local floating = vim.api.nvim_win_get_config(win).relative ~= ""
    local ft = vim.bo[buf].filetype
    local sidebar = ft:match("^snacks_")
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
  Clear = function()
    vim.cmd("silent! tabonly")
    close_extra_windows()
    Snacks.bufdelete.all()
    vim.schedule(function()
      if #Snacks.picker.get({ source = "explorer" }) == 0 then Snacks.explorer() end
    end)
  end,
  Diff = function()
    if not pcall(require("mini.diff").toggle_overlay, 0) then
      Snacks.notify.warn("No tracked changes in this buffer")
    end
  end,
  Explore = function() Snacks.explorer() end,
  Git = function() Snacks.lazygit() end,
  Grep = function() Snacks.picker.grep() end,
}

for name, run in pairs(commands) do
  vim.api.nvim_create_user_command(name, function()
    run()
    vim.schedule(function() vim.api.nvim_echo({}, false, {}) end)
  end, { range = true })
end
