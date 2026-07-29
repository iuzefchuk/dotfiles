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
  callback = function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.bo[buf].filetype == "snacks_dashboard" then
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
