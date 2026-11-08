-- Prettier para JS/TS/JSX/TSX/HTML/CSS/JSON: el mismo formato que VS Code.
-- Usa el Prettier del proyecto si lo tiene (node_modules/.bin) y, si no, el
-- fijado en tools/lsp-web. La configuración del proyecto (.prettierrc,
-- .editorconfig, .prettierignore) manda. Si Prettier no puede (falta o hay un
-- error de sintaxis), se devuelve false y se formatea con el LSP como antes.
local M = {}

M.filetypes = {
  javascript = true,
  javascriptreact = true,
  typescript = true,
  typescriptreact = true,
  html = true,
  css = true,
  scss = true,
  json = true,
  jsonc = true,
}

local function executable(path)
  local project = vim.fs.find("node_modules/.bin/prettier", { path = vim.fs.dirname(path), upward = true })[1]
  if project and vim.fn.executable(project) == 1 then return project end
  local bundled = vim.fs.joinpath(require("config.paths").web_lsp_bin(), "prettier")
  -- Sin él (copia sin actualizar) se formatea con el LSP, como antes de añadir
  -- Prettier; scripts/actualizar.sh lo instala.
  if vim.fn.executable(bundled) == 1 then return bundled end
end

-- Devuelve true si Prettier se ha encargado del buffer (aunque no cambie nada).
function M.format(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not M.filetypes[vim.bo[bufnr].filetype] then return false end
  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == "" then return false end
  local bin = executable(path)
  if not bin then return false end

  local input = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n") .. "\n"
  local ok, result = pcall(function()
    return vim.system({ bin, "--stdin-filepath", path }, {
      stdin = input,
      cwd = vim.fs.dirname(path),
      text = true,
    }):wait(3000)
  end)
  if not ok or result.code ~= 0 then return false end
  if result.stdout == input or result.stdout == "" then return true end

  local view = vim.fn.winsaveview()
  local lines = vim.split(result.stdout:gsub("\n$", ""), "\n", { plain = true })
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.fn.winrestview(view)
  return true
end

return M
