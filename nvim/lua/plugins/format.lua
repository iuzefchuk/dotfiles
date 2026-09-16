local prettier = {
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
}

local formatters_by_ft = { lua = { "stylua" }, sh = { "shfmt" } }
for _, ft in ipairs(prettier) do
  formatters_by_ft[ft] = { "prettier" }
end

local function eslint_fix_then_format(buf)
  if #vim.lsp.get_clients({ bufnr = buf, name = "eslint" }) > 0 then
    vim.api.nvim_buf_call(buf, function() pcall(vim.cmd.LspEslintFixAll) end)
  end
  return { timeout_ms = 3000 }
end

require("conform").setup({
  default_format_opts = { lsp_format = "fallback" },
  format_on_save = eslint_fix_then_format,
  formatters_by_ft = formatters_by_ft,
})
