-- Guardado real mediante BufWritePre y el servidor TypeScript instalado.
local directory = vim.fn.tempname() .. " formato ts"
vim.fn.mkdir(directory, "p")
vim.fn.writefile({ '{"private":true}' }, directory .. "/package.json")
local file = directory .. "/ejemplo.ts"
local source = {
  "function saludar() {",
  'const mensaje = "hola; señor"',
  "if (mensaje) {",
  "console.log(mensaje)",
  "}",
  "}",
  'const texto = "sin cambios"',
}
vim.fn.writefile(source, file)
vim.cmd.edit(vim.fn.fnameescape(file))
local buffer = vim.api.nvim_get_current_buf()
assert(vim.wait(15000, function()
  local clients = vim.lsp.get_clients({ bufnr = buffer, name = "ts_ls" })
  return clients[1] and clients[1]:supports_method("textDocument/formatting")
end, 50), "TypeScript no se conectó")
vim.cmd.write()
local formatted = vim.fn.readfile(file)
assert(formatted[2] == '  const mensaje = "hola; señor";', vim.inspect(formatted))
assert(formatted[3] == "  if (mensaje) {", vim.inspect(formatted))
assert(formatted[4] == "    console.log(mensaje);", vim.inspect(formatted))
assert(formatted[5] == "  }" and formatted[6] == "}", "No debe añadir ; a las llaves de control/función")
assert(formatted[7] == 'const texto = "sin cambios";', vim.inspect(formatted))
vim.api.nvim_exec_autocmds("BufWritePre", { buffer = buffer })
assert(vim.deep_equal(formatted, vim.api.nvim_buf_get_lines(buffer, 0, -1, false)), "El formato debe ser idempotente")
vim.g.entorno_formatear_al_guardar = false
vim.api.nvim_buf_set_lines(buffer, 0, -1, false, source)
vim.cmd.write()
assert(vim.deep_equal(source, vim.fn.readfile(file)), "Espacio uf debe permitir conservar el código sin formatear")
vim.g.entorno_formatear_al_guardar = true
vim.cmd("enew!")
vim.fn.delete(directory, "rf")
print("OK: guardado TypeScript, sangría, ; sintácticos, cadenas, idempotencia y desactivación")
