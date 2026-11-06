local map = vim.keymap.set

map("i", "jk", "<Esc>", { desc = "Salir del modo insertar", silent = true })

map("n", "<leader>w", "<cmd>write<cr>", { desc = "Guardar archivo" })
-- Esc también quita el resaltado de la última búsqueda (como en LazyVim).
map("n", "<Esc>", "<cmd>nohlsearch<cr><Esc>", { desc = "Quitar resaltado de búsqueda" })
map("n", "<leader>r", function() require("config.ejecutar").run() end, { desc = "Ejecutar este archivo" })

-- Espacio b: archivos abiertos (buffers).
map("n", "<leader>bb", function() require("config.navigation").pick("buffers") end, { desc = "Lista de archivos abiertos" })
map("n", "<leader>bn", function() require("config.tabline").cycle(1) end, { desc = "Archivo siguiente (]b)" })
map("n", "<leader>bp", function() require("config.tabline").cycle(-1) end, { desc = "Archivo anterior ([b)" })
map("n", "<leader>bd", "<cmd>confirm bdelete<cr>", { desc = "Cerrar este archivo (:bd)" })
map("n", "<leader>bo", function()
  local current = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= current and vim.bo[buf].buflisted and not vim.bo[buf].modified then
      vim.api.nvim_buf_delete(buf, {})
    end
  end
end, { desc = "Cerrar los demás archivos guardados" })
map("n", "]b", function() require("config.tabline").cycle(1) end, { desc = "Archivo siguiente" })
map("n", "[b", function() require("config.tabline").cycle(-1) end, { desc = "Archivo anterior" })

map("n", "<leader>gg", function()
  require("config.git").open()
end, { desc = "Abrir lazygit" })

map("n", "<leader>m", "<Nop>", { desc = "+Markdown" })
map("n", "<leader>mr", function() require("config.markdown_view").open() end,
  { desc = "Leer Markdown con mdcat" })
map("n", "<leader>md", function() require("config.markdown_view").pick() end,
  { desc = "Elegir documentación Markdown" })

if require("config.profile").has("pdf") then
  map("n", "<leader>mp", function()
    require("config.markdown_pdf").export_current()
  end, { desc = "Generar PDF del Markdown actual" })

  map("n", "<leader>mv", function()
    require("config.markdown_pdf").export_current(nil, { preview = true })
  end, { desc = "Generar y visualizar PDF del Markdown actual" })
end

if require("config.profile").has("ai") then
  map({ "n", "x" }, "<leader>ac", function()
    local mode = vim.fn.mode()
    require("config.agent_context").send({
      visual = mode == "v" or mode == "V" or mode == "\22",
    })
  end, { desc = "Enviar contexto al agente" })
end

map("n", "<leader>ul", function()
  vim.wo.list = not vim.wo.list
end, { desc = "Alternar caracteres invisibles" })

-- Espacio s: lista de todas las plantillas del lenguaje, sin recordar teclas.
-- Vive aquí (no en la config del plugin) para existir desde el arranque.
map("n", "<leader>s", function()
  if require("config.lazy").available then
    require("lazy").load({ plugins = { "mini.nvim" } })
  end
  local ok, snippets = pcall(require, "mini.snippets")
  if not ok then
    vim.notify("Las plantillas no están disponibles: repite el instalador", vim.log.levels.WARN)
    return
  end
  local line = vim.api.nvim_get_current_line()
  if not line:match("^%s*$") then
    -- Línea con texto: la plantilla va en una línea nueva debajo, con la
    -- misma sangría.
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local indent = line:match("^%s*")
    vim.api.nvim_buf_set_lines(0, row, row, false, { indent })
    vim.api.nvim_win_set_cursor(0, { row + 1, #indent })
  end
  vim.cmd("startinsert!")
  vim.schedule(function()
    snippets.expand({ match = false })
  end)
end, { desc = "Insertar plantilla (snippet)" })

-- Ortografía: Espacio o y el menú muestra las opciones.
local function spell_on()
  if not vim.wo.spell then
    vim.wo.spell = true
    vim.notify("Ortografía activada (" .. vim.o.spelllang .. ")")
  end
end

local function spell_fix()
  spell_on()
  local word = vim.fn.expand("<cword>")
  if word == "" or vim.fn.spellbadword(word)[1] == "" then
    local before = vim.api.nvim_win_get_cursor(0)
    vim.cmd("normal! ]s")
    if vim.deep_equal(before, vim.api.nvim_win_get_cursor(0)) then
      vim.notify("No hay faltas de ortografía")
      return
    end
    word = vim.fn.expand("<cword>")
  end
  local suggestions = vim.fn.spellsuggest(word, 9)
  if #suggestions == 0 then
    vim.notify("Sin sugerencias para «" .. word .. "». Espacio o a la añade como correcta.")
    return
  end
  vim.ui.select(suggestions, { prompt = "Corregir «" .. word .. "» por:" }, function(choice)
    if choice then
      vim.cmd("normal! ciw" .. choice)
      vim.cmd("stopinsert")
    end
  end)
end

map("n", "<leader>oc", spell_fix, { desc = "Corregir falta (con sugerencias)" })
map("n", "<leader>on", function() spell_on(); vim.cmd("normal! ]s") end, { desc = "Ir a la siguiente falta" })
map("n", "<leader>op", function() spell_on(); vim.cmd("normal! [s") end, { desc = "Ir a la falta anterior" })
map("n", "<leader>oa", function()
  vim.cmd("normal! zg")
  vim.notify("Añadida como correcta: " .. vim.fn.expand("<cword>"))
end, { desc = "Añadir palabra como correcta" })
map("n", "<leader>ot", function()
  vim.wo.spell = not vim.wo.spell
  vim.notify("Ortografía " .. (vim.wo.spell and "activada (" .. vim.o.spelllang .. ")" or "desactivada"))
end, { desc = "Activar o desactivar ortografía" })


-- Navegación entre ventanas Neovim
map("n", "<C-h>", "<C-w>h", { desc = "Ventana izquierda" })
map("n", "<C-j>", "<C-w>j", { desc = "Ventana inferior" })
map("n", "<C-k>", "<C-w>k", { desc = "Ventana superior" })
map("n", "<C-l>", "<C-w>l", { desc = "Ventana derecha" })


-- Edición rápida

-- Espacio t: operaciones de texto. Cada opción indica su tecla nativa entre
-- paréntesis para que se aprenda; ambas formas funcionan igual.
map("n", "<leader>td", "yyp", { desc = "Duplicar línea (yyp)" })
map("n", "<leader>tx", "dd", { desc = "Borrar línea (dd)" })
map("n", "<leader>ty", "yy", { desc = "Copiar línea (yy)" })
map("n", "<leader>tp", "p", { desc = "Pegar debajo (p)" })
map("n", "<leader>tj", "<cmd>m .+1<cr>==", { desc = "Bajar línea (Alt+Shift+j)" })
map("n", "<leader>tk", "<cmd>m .-2<cr>==", { desc = "Subir línea (Alt+Shift+k)" })
map("n", "<leader>tc", "gcc", { desc = "Comentar línea (gcc)", remap = true })
map("x", "<leader>tc", "gc", { desc = "Comentar selección (gc)", remap = true })
-- Ctrl+/ como en VS Code. Muchos terminales lo envían como Ctrl+_.
for _, lhs in ipairs({ "<C-/>", "<C-_>" }) do
  map("n", lhs, "gcc", { desc = "Comentar línea", remap = true })
  map("x", lhs, "gc", { desc = "Comentar selección", remap = true })
  map("i", lhs, "<Esc>gcca", { desc = "Comentar línea", remap = true })
end
map("n", "<leader>ta", "ggVG", { desc = "Seleccionar todo (ggVG)" })
map("n", "<leader>tu", "u", { desc = "Deshacer (u)" })
map("n", "<leader>tr", "<C-r>", { desc = "Rehacer (Ctrl+r)" })
map("n", "<leader>ts", function()
  local word = vim.fn.expand("<cword>")
  vim.api.nvim_feedkeys(":%s/\\<" .. word .. "\\>//gc", "n", false)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Left><Left><Left>", true, false, true), "n", false)
end, { desc = "Reemplazar palabra (:%s)" })


-- =========================
-- Mover líneas (Linux)
-- Alt + Shift + j/k
-- =========================

map("n", "<A-S-j>", "<cmd>m .+1<cr>==", {
  desc = "Mover línea abajo Linux",
})

map("n", "<A-S-k>", "<cmd>m .-2<cr>==", {
  desc = "Mover línea arriba Linux",
})

map("v", "<A-S-j>", ":m '>+1<cr>gv=gv", {
  desc = "Mover selección abajo Linux",
})

map("v", "<A-S-k>", ":m '<-2<cr>gv=gv", {
  desc = "Mover selección arriba Linux",
})


-- =========================
-- Mover líneas (macOS)
-- Command + Shift + flechas
-- =========================

map("n", "<D-S-Down>", "<cmd>m .+1<cr>==", {
  desc = "Mover línea abajo macOS",
})

map("n", "<D-S-Up>", "<cmd>m .-2<cr>==", {
  desc = "Mover línea arriba macOS",
})

map("v", "<D-S-Down>", ":m '>+1<cr>gv=gv", {
  desc = "Mover selección abajo macOS",
})

map("v", "<D-S-Up>", ":m '<-2<cr>gv=gv", {
  desc = "Mover selección arriba macOS",
})


-- Sangría manteniendo selección
map("v", "<", "<gv", {
  desc = "Reducir sangria",
})

map("v", ">", ">gv", {
  desc = "Aumentar sangria",
})


-- Búsqueda centrada
map("n", "n", "nzzzv", {
  desc = "Siguiente resultado centrado",
})

map("n", "N", "Nzzzv", {
  desc = "Resultado anterior centrado",
})


-- Terminal integrada
map("t", "<Esc><Esc>", [[<C-\><C-n>]], {
  desc = "Salir del modo terminal",
})


-- Diagnósticos LSP

map("n", "]d", function()
  vim.diagnostic.jump({
    count = 1,
    float = true,
  })
end, {
  desc = "Diagnostico siguiente",
})

map("n", "[d", function()
  vim.diagnostic.jump({
    count = -1,
    float = true,
  })
end, {
  desc = "Diagnostico anterior",
})

map("n", "<leader>ld", function()
  vim.diagnostic.open_float({ scope = "buffer" })
end, {
  desc = "Mostrar diagnostico",
})

map("n", "gl", function()
  vim.diagnostic.open_float({ scope = "line" })
end, {
  desc = "Mostrar diagnosticos de esta linea",
})

-- Sin atajos que empiecen por Espacio e: así actúa al instante.
map("n", "<leader>e", function()
  require("config.navigation").explorer()
end, { desc = "Abrir explorador" })
