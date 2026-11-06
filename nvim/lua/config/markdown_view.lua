local M = {}

local function warn(message)
  vim.notify(message, vim.log.levels.WARN)
end

function M.open(path)
  local current = vim.api.nvim_buf_get_name(0)
  path = path or current
  if path == "" then return warn("Guarda primero el documento Markdown.") end
  path = vim.fn.fnamemodify(path, ":p")
  if not path:lower():match("%.md$") and not path:lower():match("%.markdown$") then
    return warn("Selecciona un archivo Markdown (.md o .markdown).")
  end
  if vim.fn.filereadable(path) ~= 1 then return warn("No se puede leer: " .. path) end
  local buffer = vim.fn.bufnr(path)
  if buffer >= 0 and vim.bo[buffer].modified then
    return warn("Hay cambios sin guardar. Pulsa Espacio w y después Espacio m r.")
  end
  if vim.fn.executable("mdcat") ~= 1 then
    return warn("Falta mdcat. No se ha instalado nada; consulta docs/visor-markdown.md.")
  end
  local script = require("config.paths").repository() .. "/scripts/markdown-view.sh"
  if vim.env.TMUX and vim.env.TMUX ~= "" then
    local command = { "bash", script, "--open", vim.env.TMUX_PANE or "", path }
    vim.system(command, { text = true, env = require("config.process").desktop_env() }, function(result)
      if result.code ~= 0 then
        vim.schedule(function() warn(vim.trim(result.stderr or "No se pudo abrir mdcat.")) end)
      end
    end)
  else
    -- La terminal de Neovim conserva la salida; las imágenes dependen de su emulador.
    vim.cmd("botright new")
    local buffer = vim.api.nvim_get_current_buf()
    vim.bo[buffer].bufhidden = "wipe"
    local job = vim.fn.jobstart({ "bash", script, "--view", path }, {
      term = true,
      env = require("config.process").desktop_env(),
      on_exit = vim.schedule_wrap(function()
        if vim.api.nvim_buf_is_valid(buffer) then vim.api.nvim_buf_delete(buffer, { force = true }) end
      end),
    })
    if job <= 0 then
      vim.api.nvim_buf_delete(buffer, { force = true })
      return warn("No se pudo iniciar mdcat.")
    end
    vim.cmd.startinsert()
  end
end

function M.pick()
  if vim.fn.executable("rg") ~= 1 then return warn("Falta rg para buscar documentación.") end
  if not require("config.lazy").available then
    return warn("El selector necesita fzf-lua. Puedes abrir el Markdown y pulsar Espacio m r.")
  end
  require("fzf-lua").files({
    prompt = "Markdown> ",
    cmd = "rg --files --hidden -g '*.md' -g '*.markdown' -g '*.MD'"
      .. " -g '!**/.git/**' -g '!**/node_modules/**' -g '!**/.xdg/**' -g '!**/.tools/**'",
    actions = {
      ["enter"] = function(selected, opts)
        if selected and selected[1] then
          local entry = require("fzf-lua.path").entry_to_file(selected[1], opts)
          M.open(entry.path)
        end
      end,
    },
  })
end

return M
