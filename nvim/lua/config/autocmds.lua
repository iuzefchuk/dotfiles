-- Automatically open the file explorer on startup.
-- Note: LazyVim defers loading this file until the `VeryLazy` event when nvim
-- is launched with no file argument, which is *after* `VimEnter` has already
-- fired. So we can't rely solely on a `VimEnter` autocmd -- we check whether
-- startup has already finished and open the explorer directly in that case.
local function open_explorer()
  vim.schedule(function()
    require("snacks").explorer()
  end)
end

if vim.v.vim_did_enter == 1 then
  -- Startup already finished (no-file launch: this file loaded on VeryLazy).
  open_explorer()
else
  -- Launched with a file arg: this file loaded before VimEnter, so wait for it.
  vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = open_explorer,
  })
end

-- Go back to the dashboard once the last real buffer is closed. Snacks' bufdelete
-- (which LazyVim's `<leader>bd` and bufferline's close both use) never quits nvim:
-- when the buffer being deleted is the last listed one it creates a fresh nameless
-- scratch buffer to put in the window instead. So we end up staring at an empty
-- buffer rather than the dashboard. Detect exactly that state and re-open it.
local function no_real_buffers_left()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
      -- Named buffer, or an unnamed one the user has typed into: real work.
      if vim.api.nvim_buf_get_name(buf) ~= "" or vim.api.nvim_buf_line_count(buf) > 1 then
        return false
      end
      local first = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1]
      if first and first ~= "" then
        return false
      end
    end
  end
  return true
end

-- The window the dashboard belongs in: a normal, non-floating one that isn't the
-- explorer sidebar or any other snacks picker window. Without this we'd open it
-- in whatever window happened to be focused, which replaces the sidebar when the
-- last buffer is closed from inside the explorer.
local function main_win()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local ft = vim.bo[vim.api.nvim_win_get_buf(win)].filetype
    if vim.api.nvim_win_get_config(win).relative == "" and not ft:match("^snacks_") then
      return win
    end
  end
end

vim.api.nvim_create_autocmd("BufDelete", {
  callback = function()
    -- Deferred: at BufDelete time the buffer is still in the list, and bufdelete
    -- has not yet swapped the replacement buffer into the window.
    vim.schedule(function()
      if vim.bo.filetype == "snacks_dashboard" or not no_real_buffers_left() then
        return
      end
      local win = main_win()
      if win then
        require("snacks").dashboard.open({ win = win })
      end
    end)
  end,
})

-- Silently discard stale swap files instead of showing the "swap file already
-- exists" prompt. nvim leaves a swap behind whenever a session is killed without
-- a clean quit (e.g. closing the terminal window while nvim is open). We read the
-- process ID recorded in the swap file; if that process is no longer running on
-- this host, the swap is a leftover and safe to delete. A live process (a real
-- second instance editing the same file) still gets the normal prompt.
vim.api.nvim_create_autocmd("SwapExists", {
  callback = function()
    local swap = vim.v.swapname
    local fh = io.open(swap, "rb")
    if not fh then
      return
    end
    local header = fh:read(108) or ""
    fh:close()
    if #header < 108 then
      return
    end

    -- Vim swap header (block0): b0_pid is 4 bytes, little-endian, at offset 24;
    -- b0_hname (host name) is 40 bytes at offset 68.
    local p = { header:byte(25, 28) }
    local pid = p[1] + p[2] * 256 + p[3] * 65536 + p[4] * 16777216
    local host = (header:sub(69, 108):gsub("%z.*$", ""))

    local this_host = vim.uv.os_gethostname()
    local same_host = host == "" or host == this_host or vim.startswith(host, this_host)
    -- kill(pid, 0) probes existence without sending a signal: 0 => alive.
    local alive = pid > 0 and vim.uv.kill(pid, 0) == 0

    if same_host and not alive then
      vim.v.swapchoice = "d" -- delete the stale swap and edit the file normally
    end
  end,
})
