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

local has_parser = {}
local function prettier_has_parser(_, ctx)
  if has_parser[ctx.filename] == nil then
    local out = vim.fn.system({ "prettier", "--file-info", ctx.filename })
    local ok, info = pcall(vim.json.decode, out)
    local parser = ok and type(info) == "table" and info.inferredParser or nil
    has_parser[ctx.filename] = parser ~= nil and parser ~= vim.NIL
  end
  return has_parser[ctx.filename]
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
