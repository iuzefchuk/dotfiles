if vim.fn.argc(-1) == 0 then
  vim.api.nvim_create_autocmd("VimEnter", { callback = vim.schedule_wrap(function() Snacks.explorer() end) })
end

vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  callback = function()
    if vim.o.buftype ~= "nofile" then vim.cmd("checktime") end
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", { callback = function() vim.hl.on_yank() end })

vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function(event)
    if vim.b[event.buf].last_loc or vim.filetype.match({ buf = event.buf }) == "gitcommit" then return end
    vim.b[event.buf].last_loc = true
    pcall(vim.api.nvim_win_set_cursor, 0, vim.api.nvim_buf_get_mark(event.buf, '"'))
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "text", "plaintex", "gitcommit", "markdown" },
  callback = function() vim.opt_local.spell = true end,
})
