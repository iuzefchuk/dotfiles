local function augroup(name)
  return vim.api.nvim_create_augroup("config_" .. name, { clear = true })
end

local function open_explorer()
  vim.schedule(function()
    require("snacks").explorer()
  end)
end

if vim.v.vim_did_enter == 1 then
  open_explorer()
else
  vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = open_explorer,
  })
end

local function no_real_buffers_left()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
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

local function main_win()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local ft = vim.bo[vim.api.nvim_win_get_buf(win)].filetype
    if vim.api.nvim_win_get_config(win).relative == "" and not ft:match("^snacks_") then
      return win
    end
  end
end

vim.api.nvim_create_autocmd("WinScrolled", {
  group = augroup("dashboard_scroll"),
  callback = function()
    for id in pairs(vim.v.event) do
      local win = tonumber(id)
      local buf = win and vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win)
      if buf and vim.bo[buf].filetype == "snacks_dashboard" then
        local max_top = math.max(1, vim.api.nvim_buf_line_count(buf) - vim.api.nvim_win_get_height(win) + 1)
        vim.api.nvim_win_call(win, function()
          local view = vim.fn.winsaveview()
          if view.topline > max_top then
            view.topline = max_top
            vim.fn.winrestview(view)
          end
        end)
      end
    end
  end,
})

vim.api.nvim_create_autocmd("BufDelete", {
  group = augroup("dashboard_reopen"),
  callback = function()
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

vim.api.nvim_create_autocmd("SwapExists", {
  group = augroup("swap"),
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

    local p = { header:byte(25, 28) }
    local pid = p[1] + p[2] * 256 + p[3] * 65536 + p[4] * 16777216
    local host = (header:sub(69, 108):gsub("%z.*$", ""))

    local this_host = vim.uv.os_gethostname()
    local same_host = host == "" or host == this_host or vim.startswith(host, this_host)
    local alive = pid > 0 and vim.uv.kill(pid, 0) == 0

    if same_host and not alive then
      vim.v.swapchoice = "d"
    end
  end,
})

-- reload the file when it changed elsewhere
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    (vim.hl or vim.highlight).on_yank()
  end,
})

vim.api.nvim_create_autocmd("VimResized", {
  group = augroup("resize_splits"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- restore cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function(event)
    local buf = event.buf
    if vim.bo[buf].filetype == "gitcommit" or vim.b[buf].last_loc then
      return
    end
    vim.b[buf].last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- close throwaway windows with q (grug-far, help, quickfix, ...)
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "checkhealth",
    "grug-far",
    "help",
    "lspinfo",
    "notify",
    "qf",
    "startuptime",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set("n", "q", function()
        vim.cmd("close")
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, { buffer = event.buf, silent = true, desc = "Quit buffer" })
    end)
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup("spell"),
  pattern = { "text", "plaintex", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.spell = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup("json_conceal"),
  pattern = { "json", "jsonc", "json5" },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

-- create missing parent directories on save
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})
