if vim.fn.argc(-1) == 0 then
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = vim.schedule_wrap(function() Snacks.explorer() end),
  })
end

vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  callback = function()
    if vim.o.buftype ~= "nofile" then vim.cmd("checktime") end
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function() vim.hl.on_yank() end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function(event)
    local buf = event.buf
    if vim.b[buf].last_loc or vim.filetype.match({ buf = buf }) == "gitcommit" then return end
    vim.b[buf].last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(buf) then pcall(vim.api.nvim_win_set_cursor, 0, mark) end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "text", "plaintex", "gitcommit", "markdown" },
  callback = function() vim.opt_local.spell = true end,
})
