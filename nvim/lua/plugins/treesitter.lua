require("nvim-treesitter").install({
  "bash",
  "css",
  "html",
  "javascript",
  "json",
  "lua",
  "typescript",
  "vue",
})

vim.api.nvim_create_autocmd("FileType", {
  callback = function(event)
    if pcall(vim.treesitter.start, event.buf) then
      vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      vim.wo[0][0].foldmethod = "expr"
      vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
    end
  end,
})
