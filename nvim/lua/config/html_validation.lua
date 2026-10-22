local M = {}
M.namespace = vim.api.nvim_create_namespace("entorno_html_validation")
local pending = {}
local warned = {}

local function available(bufnr)
  return vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_is_loaded(bufnr)
    and vim.bo[bufnr].filetype == "html" and vim.bo[bufnr].buftype == ""
end

local function cancel(bufnr)
  local old = pending[bufnr]
  pending[bufnr] = nil
  if old and old.process then old.process:kill(15) end
end

local function failure(bufnr)
  vim.diagnostic.reset(M.namespace, bufnr)
  if warned[bufnr] then return end
  warned[bufnr] = true
  vim.notify("Validación HTML no disponible: ejecute scripts/instalar-lsp-web.sh", vim.log.levels.WARN)
end

function M.validate(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  cancel(bufnr)
  if not available(bufnr) then
    vim.diagnostic.reset(M.namespace, bufnr)
    return
  end
  local state = {}
  pending[bufnr] = state
  vim.defer_fn(function()
    if pending[bufnr] ~= state or not available(bufnr) then return end
    local root = require("config.paths").repository()
    local node = vim.fn.exepath("node")
    local script = vim.fs.joinpath(root, "tools", "lsp-web", "validar-html.cjs")
    if node == "" or vim.fn.filereadable(script) ~= 1 then
      pending[bufnr] = nil
      failure(bufnr)
      return
    end
    local tick = vim.api.nvim_buf_get_changedtick(bufnr)
    local text = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n")
    state.process = vim.system({ node, script }, { stdin = text, text = true, timeout = 5000 },
      vim.schedule_wrap(function(result)
        if pending[bufnr] ~= state or not available(bufnr)
          or vim.api.nvim_buf_get_changedtick(bufnr) ~= tick then return end
        pending[bufnr] = nil
        local ok, items = pcall(vim.json.decode, result.stdout or "")
        if result.code ~= 0 or not ok or type(items) ~= "table" then failure(bufnr); return end
        warned[bufnr] = nil
        local diagnostics = {}
        for _, item in ipairs(items) do
          diagnostics[#diagnostics + 1] = {
            lnum = item.start.line, col = item.start.column,
            end_lnum = item["end"].line, end_col = item["end"].column,
            message = item.message, code = item.code, source = "html-validate",
            severity = item.severity == 2 and vim.diagnostic.severity.ERROR or vim.diagnostic.severity.WARN,
          }
        end
        vim.diagnostic.set(M.namespace, bufnr, diagnostics)
      end))
  end, 400)
end

function M.setup()
  local group = vim.api.nvim_create_augroup("entorno_html_validation", { clear = true })
  vim.api.nvim_create_autocmd({ "FileType", "BufEnter", "BufWritePost", "TextChanged", "TextChangedI", "InsertLeave" }, {
    group = group,
    callback = function(event)
      if vim.bo[event.buf].filetype == "html" or pending[event.buf] or event.event == "FileType" then
        M.validate(event.buf)
      end
    end,
  })
  vim.api.nvim_create_autocmd({ "BufUnload", "BufWipeout" }, {
    group = group,
    callback = function(event) cancel(event.buf); warned[event.buf] = nil end,
  })
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if available(bufnr) then M.validate(bufnr) end
  end
end

return M
