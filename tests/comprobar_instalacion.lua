local root = assert(vim.env.ENTORNO_NVIM_ROOT)
local xdg = assert(vim.env.ENTORNO_NVIM_XDG_ROOT)
local paths = require("config.paths")

assert(vim.fn.stdpath("config") == root .. "/nvim", "configuracion aislada incorrecta")
assert(vim.fn.stdpath("data") == xdg .. "/data/nvim", "datos fuera del XDG temporal")
assert(vim.fn.stdpath("state") == xdg .. "/state/profesor/nvim", "estado fuera del XDG temporal")
assert(vim.fn.stdpath("cache") == xdg .. "/cache/nvim", "cache fuera del XDG temporal")

for _, module in ipairs({
  "config.options",
  "config.keymaps",
  "config.autocmds",
  "config.lazy",
  "config.lsp",
  "config.html_validation",
  "config.completion",
  "config.markdown_pdf",
}) do
  assert(package.loaded[module], module .. " no se cargo")
end

local lock = vim.json.decode(table.concat(vim.fn.readfile(root .. "/nvim/lazy-lock.json"), "\n"))
local lazy = require("lazy.core.config")
for plugin, _ in pairs(lock) do
  assert(lazy.plugins[plugin], "plugin no registrado: " .. plugin)
  local expected = xdg .. "/data/nvim/lazy/" .. plugin
  assert(lazy.plugins[plugin].dir == expected, "plugin fuera del XDG temporal: " .. plugin)
end
require("lazy").load({ plugins = { "fzf-lua", "nvim-tree.lua", "nvim-web-devicons", "mini.nvim" } })
assert(package.loaded["fzf-lua"], "fzf-lua no se cargo")
assert(package.loaded["nvim-tree"], "nvim-tree no se cargo")
assert(pcall(require, "nvim-web-devicons"), "nvim-web-devicons no se pudo cargar")

for _, executable in ipairs({
  "typescript-language-server",
  "vscode-html-language-server",
  "vscode-css-language-server",
  "vscode-json-language-server",
  "tailwindcss-language-server",
}) do
  assert(vim.fn.executable(paths.web_lsp_bin() .. "/" .. executable) == 1, "falta LSP: " .. executable)
end
assert(vim.fn.executable(paths.python_lsp_bin() .. "/pyright-langserver") == 1, "falta Pyright")
assert(vim.fn.executable(paths.luals_bin()) == 1, "falta LuaLS")
assert(vim.fn.executable(paths.tree_sitter_bin()) == 1, "falta tree-sitter CLI")
assert(vim.treesitter.language.add("python"), "parser Python no cargable")
assert(vim.fn.exists(":MarkdownPdf") == 2, "falta MarkdownPdf")
