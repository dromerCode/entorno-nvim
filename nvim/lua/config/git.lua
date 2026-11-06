local M = {}

-- Repositorio del archivo actual o, si no, de la carpeta de trabajo.
local function project_root()
  return vim.fs.root(0, { ".git" }) or vim.fs.root(vim.fn.getcwd(), { ".git" })
end

-- Repositorios en subcarpetas (hasta dos niveles), p. ej. ~/DWEC/tema1.
local function child_repos()
  local cwd = vim.fn.getcwd()
  local found = {}
  for name, kind in vim.fs.dir(cwd, {
    depth = 3,
    skip = function(dir) return dir ~= "node_modules" and not dir:match("/%.git$") end,
  }) do
    if kind == "directory" and (name == ".git" or name:match("/%.git$")) then
      local dir = vim.fs.dirname(cwd .. "/" .. name)
      if dir ~= cwd then table.insert(found, dir) end
    end
  end
  table.sort(found)
  return found
end

local launch

function M.open(command)
  if vim.fn.executable("lazygit") ~= 1 then
    vim.notify("lazygit no esta disponible", vim.log.levels.ERROR)
    return
  end

  local root = project_root()
  if root then return launch(root, command) end

  local repos = child_repos()
  if #repos == 1 then return launch(repos[1], command) end
  if #repos == 0 then
    vim.notify("Aquí no hay ningún repositorio Git. Abre un archivo del proyecto"
      .. " o, si quieres crear uno, ejecuta: git init", vim.log.levels.WARN)
    return
  end
  vim.ui.select(repos, {
    prompt = "¿Qué repositorio abro? ",
    format_item = function(dir) return vim.fn.fnamemodify(dir, ":~:.") end,
  }, function(dir)
    if dir then vim.schedule(function() launch(dir, command) end) end
  end)
end

launch = function(cwd, command)
  local previous_window = vim.api.nvim_get_current_win()
  local buffer = vim.api.nvim_create_buf(false, true)
  local width = math.max(1, math.floor(vim.o.columns * 0.9))
  local height = math.max(1, math.floor(vim.o.lines * 0.9))
  local window = vim.api.nvim_open_win(buffer, true, {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = "rounded",
  })

  vim.bo[buffer].bufhidden = "wipe"
  vim.bo[buffer].filetype = "lazygit"

  local job = vim.fn.jobstart(command or {
    "sh", require("config.paths").repository() .. "/scripts/lazygit.sh",
  }, {
    cwd = cwd,
    env = require("config.process").desktop_env(),
    term = true,
    on_exit = vim.schedule_wrap(function()
      if vim.api.nvim_win_is_valid(window) then
        vim.api.nvim_win_close(window, true)
      end
      if vim.api.nvim_win_is_valid(previous_window) then
        vim.api.nvim_set_current_win(previous_window)
      end
    end),
  })

  if job <= 0 then
    vim.api.nvim_win_close(window, true)
    vim.notify("No se pudo iniciar lazygit", vim.log.levels.ERROR)
    return
  end

  vim.cmd.startinsert()
end

return M
