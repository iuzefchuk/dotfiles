local prettier_parsers = {
  css = "css",
  graphql = "graphql",
  handlebars = "glimmer",
  html = "html",
  javascript = "babel",
  javascriptreact = "babel",
  json = "json",
  jsonc = "jsonc",
  less = "less",
  markdown = "markdown",
  ["markdown.mdx"] = "mdx",
  scss = "scss",
  typescript = "typescript",
  typescriptreact = "typescript",
  vue = "vue",
  yaml = "yaml",
}

local function formatters_by_ft()
  local ft = { lua = { "stylua" }, sh = { "shfmt" } }
  for name in pairs(prettier_parsers) do
    ft[name] = { "prettier" }
  end
  return ft
end

local function prettier_parser(_, ctx)
  local parser = prettier_parsers[vim.bo[ctx.buf].filetype]
  return parser and { "--parser", parser } or {}
end

local function eslint_fix_then_format(buf)
  if #vim.lsp.get_clients({ bufnr = buf, name = "eslint" }) > 0 then
    vim.api.nvim_buf_call(buf, function()
      pcall(vim.cmd.LspEslintFixAll)
    end)
  end
  return { timeout_ms = 3000 }
end

require("conform").setup({
  default_format_opts = { lsp_format = "fallback" },
  format_on_save = eslint_fix_then_format,
  formatters_by_ft = formatters_by_ft(),
  formatters = {
    prettier = { prepend_args = prettier_parser },
  },
})
