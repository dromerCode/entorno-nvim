local M = {}
local url = "https://dromercode.github.io/chuleta-entorno-nvim/"
local function notify(message) vim.notify(message, vim.log.levels.WARN) end
function M.web()
  local cmd
  if vim.fn.has("mac") == 1 then cmd = { "open", url }
  elseif vim.fn.has("wsl") == 1 and vim.fn.executable("wslview") == 1 then cmd = { "wslview", url }
  elseif vim.fn.has("wsl") == 1 and vim.fn.executable("explorer.exe") == 1 then cmd = { "explorer.exe", url }
  elseif vim.fn.executable("xdg-open") == 1 then cmd = { "xdg-open", url }
  else return notify("No se encontró un navegador para abrir: " .. url) end
  vim.system(cmd, { detach = true, env = require("config.process").desktop_env() }, function(result)
    if result.code ~= 0 then vim.schedule(function() notify("No se pudo abrir: " .. url) end) end
  end)
end
function M.open()
  local cache = vim.fs.joinpath(vim.fn.stdpath("cache"), "chuleta-alumno.md")
  if vim.fn.filereadable(cache) == 1 then return require("config.markdown_view").open(cache) end
  if vim.fn.executable("python3") ~= 1 or vim.fn.executable("pandoc") ~= 1 then
    return notify("La primera descarga necesita python3 y pandoc. También puede abrir la web con w.")
  end
  local script = vim.fs.joinpath(require("config.paths").repository(), "scripts", "chuleta-descargar.py")
  vim.notify("Descargando y preparando la chuleta…")
  vim.system({ "python3", script, cache }, { text = true }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then return notify("No se pudo descargar la chuleta: " .. vim.trim(result.stderr or "")) end
      require("config.markdown_view").open(cache)
    end)
  end)
end
return M
