local validation = require("config.html_validation")
assert(package.loaded["config.html_validation"], "No se configura la validación HTML")
vim.lsp.enable("html", false)
local bufnr = vim.api.nvim_create_buf(true, false)
vim.api.nvim_set_current_buf(bufnr)
vim.bo[bufnr].filetype = "html"
local function diagnostics() return vim.diagnostic.get(bufnr, { namespace = validation.namespace }) end
local function replace(lines)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.api.nvim_exec_autocmds("TextChanged", { buffer = bufnr })
end
replace({ '<p idddd="datos">atención</p>', '<p id="igual"></p>', '<p id="igual"></p>',
  '<input type="text"></input>', '<footerr></footerr>' })
assert(vim.wait(6000, function() return #diagnostics() >= 4 end, 30), "No llegan diagnósticos del HTML sin guardar")
local found = {}
for _, item in ipairs(diagnostics()) do
  found[item.code] = item
  assert(item.source == "html-validate" and item.severity == vim.diagnostic.severity.ERROR)
end
for _, code in ipairs({ "no-unknown-attributes", "no-dup-id", "void-content", "no-unknown-elements" }) do
  assert(found[code], "Falta " .. code)
end
assert(found["no-unknown-attributes"].lnum == 0 and found["no-unknown-attributes"].col == 3)
assert(found["no-dup-id"].lnum == 2)

-- Corregir sin guardar quita los errores, sin exigir doctype/head a un fragmento.
replace({ '<main><p id="datos" data-nota="1" aria-label="Atención">atención</p><input type="text">',
  '<p id="otro"></p><my-widget data-value="1"></my-widget></main>' })
assert(vim.wait(6000, function() return #diagnostics() == 0 end, 30), "Persisten errores tras corregir el fragmento")

local unicode = '<p>atención 🦗</p><p idddd="datos"></p>'
replace({ unicode })
assert(vim.wait(6000, function() return #diagnostics() == 1 end, 30), "Falta diagnóstico con Unicode")
local item = diagnostics()[1]
assert(item.col == unicode:find("idddd", 1, true) - 1, "Columnas desplazadas tras caracteres UTF-8")
assert(item.end_col == item.col + 5)

-- Una respuesta de una versión anterior nunca debe reponer sus errores.
replace({ '<p idddd="viejo"></p>' })
vim.wait(450)
replace({ '<p id="actual"></p>' })
assert(vim.wait(6000, function() return #diagnostics() == 0 end, 30))
vim.wait(700)
assert(#diagnostics() == 0, "Llegó una respuesta obsoleta")

replace({ '<p idddd="datos"></p>' })
assert(vim.wait(6000, function() return #diagnostics() > 0 end, 30))
vim.bo[bufnr].filetype = "javascript"
assert(#diagnostics() == 0, "Los diagnósticos HTML sobreviven al cambio de lenguaje")
vim.api.nvim_buf_delete(bufnr, { force = true })
print("OK: validación HTML local, sin guardar, corrección, UTF-8 y descarte de respuestas obsoletas")
