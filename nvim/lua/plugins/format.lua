local formatters_by_ft = { lua = { "stylua" }, sh = { "shfmt" } }
for _, ft in ipairs({
  "css",
  "graphql",
  "handlebars",
  "html",
  "javascript",
  "javascriptreact",
  "json",
  "jsonc",
  "less",
  "markdown",
  "markdown.mdx",
  "scss",
  "typescript",
  "typescriptreact",
  "vue",
  "yaml",
}) do
  formatters_by_ft[ft] = { "prettier" }
end

require("conform").setup({
  default_format_opts = { lsp_format = "fallback" },
  format_on_save = function(buf)
    vim.api.nvim_buf_call(buf, function() pcall(vim.cmd.LspEslintFixAll) end)
    return { timeout_ms = 3000 }
  end,
  formatters_by_ft = formatters_by_ft,
})
