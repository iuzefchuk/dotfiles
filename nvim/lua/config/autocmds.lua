if vim.fn.argc(-1) == 0 then
  vim.api.nvim_create_autocmd("VimEnter", { callback = vim.schedule_wrap(function() Snacks.explorer() end) })
end

vim.api.nvim_create_autocmd("TextYankPost", { callback = function() vim.hl.on_yank() end })

vim.api.nvim_create_autocmd("SwapExists", {
  callback = function()
    local info = vim.fn.swapinfo(vim.v.swapname)
    if not info.error and info.pid == 0 and info.dirty == 0 then vim.v.swapchoice = "d" end
  end,
})
