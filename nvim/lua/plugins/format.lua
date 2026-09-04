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
local function prettier_has_parser(self, ctx)
  local cmd = self.command
  if type(cmd) == "function" then
    cmd = cmd(self, ctx)
  end

  local name = vim.fn.fnamemodify(ctx.filename, ":t")
  local key = cmd .. "\0" .. (name:match("^.+%.([^.]+)$") or name)
  if has_parser[key] == nil then
    local out = vim.fn.system({ cmd, "--file-info", ctx.filename })
    local ok, info = pcall(vim.json.decode, out)
    local parser = ok and type(info) == "table" and info.inferredParser or nil
    has_parser[key] = parser ~= nil and parser ~= vim.NIL
  end
  return has_parser[key]
end

local function eslint_fix_then_format(buf)
  if #vim.lsp.get_clients({ bufnr = buf, name = "eslint" }) > 0 then
    vim.api.nvim_buf_call(buf, function()
      pcall(vim.cmd, "LspEslintFixAll")
    end)
  end
  return { timeout_ms = 3000 }
end

return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  cmd = "ConformInfo",
  opts = {
    default_format_opts = { lsp_format = "fallback" },
    format_on_save = eslint_fix_then_format,
    formatters_by_ft = formatters_by_ft(),
    formatters = {
      prettier = { condition = prettier_has_parser },
    },
  },
}
