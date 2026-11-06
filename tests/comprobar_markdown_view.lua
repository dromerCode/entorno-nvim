local view = require("config.markdown_view")
local work = vim.fn.tempname() .. " documentación"
vim.fn.mkdir(work, "p")
local file = work .. "/léeme $(sin ejecutar).md"
vim.fn.writefile({ "# Documento", "", "Contenido" }, file)
local original = { notify = vim.notify, system = vim.system, executable = vim.fn.executable }
local tmux, pane = vim.env.TMUX, vim.env.TMUX_PANE
local notices, commands = {}, {}
vim.notify = function(message) notices[#notices + 1] = message end
vim.fn.executable = function(command)
  if command == "mdcat" then return 1 end
  return original.executable(command)
end
vim.system = function(command) commands[#commands + 1] = command end
vim.env.TMUX, vim.env.TMUX_PANE = "test", "%42"
view.open(file)
assert(#commands == 1 and commands[1][5] == file, "La ruta debe ser un argumento sin interpolar")
assert(commands[1][4] == "%42", "Debe conservar el panel de origen")
vim.cmd.edit(vim.fn.fnameescape(file))
vim.api.nvim_buf_set_lines(0, 0, 1, false, { "# Modificado" })
view.open()
assert(#commands == 1 and notices[#notices]:find("sin guardar"), "No debe mostrar silenciosamente una versión antigua")
view.open(work .. "/no existe.md")
assert(#commands == 1 and notices[#notices]:find("No se puede leer"))
view.open(work .. "/archivo.js")
assert(#commands == 1 and notices[#notices]:find("Markdown"))
vim.fn.executable = function(command) return command == "mdcat" and 0 or original.executable(command) end
view.open(file)
assert(#commands == 1 and notices[#notices]:find("sin guardar"))
vim.bo.modified = false
view.open(file)
assert(#commands == 1 and notices[#notices]:find("Falta mdcat"))
vim.fn.executable = function(command)
  return command == "mdcat" and 1 or original.executable(command)
end
require("lazy").load({ plugins = { "fzf-lua" } })
local fzf = require("fzf-lua")
local files, picker = fzf.files, nil
fzf.files = function(opts) picker = opts end
view.pick()
assert(picker and picker.cmd:find("%.md"), "Debe filtrar Markdown")
picker.actions.enter({}, {})
assert(#commands == 1, "Cancelar no debe abrir nada")
picker.actions.enter({ file }, {})
assert(#commands == 2 and commands[2][5] == file, "El selector debe conservar espacios y caracteres especiales")
fzf.files = files
vim.notify, vim.system, vim.fn.executable = original.notify, original.system, original.executable
-- Probar la terminal alternativa sin depender de mdcat instalado en el equipo.
local previous_path = vim.env.PATH
local fake = work .. "/mdcat"
vim.fn.writefile({ "#!/bin/sh", "printf 'Documento representado\\n'" }, fake)
vim.fn.setfperm(fake, "rwx------")
vim.env.PATH = work .. ":" .. previous_path
vim.env.TMUX, vim.env.TMUX_PANE = nil, nil
view.open(file)
local terminal = vim.api.nvim_get_current_buf()
assert(vim.bo[terminal].buftype == "terminal")
assert(vim.wait(3000, function()
  return table.concat(vim.api.nvim_buf_get_lines(terminal, 0, -1, false), "\n"):find("q: cerrar") ~= nil
end), "La terminal alternativa debe representar y esperar")
vim.api.nvim_chan_send(vim.b[terminal].terminal_job_id, "q")
assert(vim.wait(3000, function() return not vim.api.nvim_buf_is_valid(terminal) end), "q debe cerrar la terminal")
vim.env.PATH = previous_path
vim.env.TMUX, vim.env.TMUX_PANE = tmux, pane
vim.cmd("enew!")
vim.fn.delete(work, "rf")
assert(vim.fn.maparg("<leader>mr", "n", false, true).desc == "Leer Markdown con mdcat")
assert(vim.fn.maparg("<leader>md", "n", false, true).desc == "Elegir documentación Markdown")
print("OK: Markdown, rutas literales, cambios sin guardar, ausencias, selector y terminal sin tmux")
