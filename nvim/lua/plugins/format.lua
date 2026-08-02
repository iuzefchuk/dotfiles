local prettier_filetypes = {
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
  "svelte",
  "typescript",
  "typescriptreact",
  "vue",
  "yaml",
}

local function formatters_by_ft()
  local ft = { lua = { "stylua" }, sh = { "shfmt" } }
  for _, name in ipairs(prettier_filetypes) do
    ft[name] = { "prettier" }
  end
  return ft
end

-- prettier errors out on files it has no parser for; skip those instead.
local function prettier_has_parser(_, ctx)
  if vim.tbl_contains(prettier_filetypes, vim.bo[ctx.buf].filetype) then
    return true
  end
  local out = vim.fn.system({ "prettier", "--file-info", ctx.filename })
  local ok, parser = pcall(function()
    return vim.fn.json_decode(out).inferredParser
  end)
  return ok and parser ~= nil and parser ~= vim.NIL
end

return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  cmd = "ConformInfo",
  opts = {
    default_format_opts = { lsp_format = "fallback" },
    format_on_save = { timeout_ms = 3000 },
    formatters_by_ft = formatters_by_ft(),
    formatters = {
      prettier = { condition = prettier_has_parser },
    },
  },
}
