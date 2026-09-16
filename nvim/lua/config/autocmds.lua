if vim.fn.argc(-1) == 0 then
  vim.api.nvim_create_autocmd("VimEnter", { callback = vim.schedule_wrap(function() Snacks.explorer() end) })
end

vim.api.nvim_create_autocmd("TextYankPost", { callback = function() vim.hl.on_yank() end })
