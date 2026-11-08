-- Guardado real mediante BufWritePre con el Prettier fijado en tools/lsp-web.
local bin = vim.fs.joinpath(require("config.paths").web_lsp_bin(), "prettier")
assert(vim.fn.executable(bin) == 1, "Falta Prettier: ejecute scripts/instalar-lsp-web.sh")

local directory = vim.fn.tempname() .. " formato prettier"
vim.fn.mkdir(directory, "p")
vim.fn.writefile({ '{"private":true}' }, directory .. "/package.json")

local function save(name, source)
  local file = directory .. "/" .. name
  vim.fn.writefile(source, file)
  vim.cmd.edit(vim.fn.fnameescape(file))
  vim.cmd.write()
  return vim.fn.readfile(file), vim.api.nvim_get_current_buf()
end

-- JavaScript: comillas, puntos y coma y sangría, sin depender del LSP.
local js = save("ejemplo.js", {
  "function saludar(nombre){",
  "const texto='hola '+nombre",
  "if(texto){console.log(texto)}",
  "}",
})
assert(vim.deep_equal(js, {
  "function saludar(nombre) {",
  '  const texto = "hola " + nombre;',
  "  if (texto) {",
  "    console.log(texto);",
  "  }",
  "}",
}), vim.inspect(js))

-- HTML y CSS también pasan por Prettier.
local html = save("index.html", { "<ul><li>uno</li><li>dos</li></ul>" })
assert(vim.deep_equal(html, { "<ul>", "  <li>uno</li>", "  <li>dos</li>", "</ul>" }), vim.inspect(html))
local css = save("estilos.css", { "body{margin:0;color:red}" })
assert(vim.deep_equal(css, { "body {", "  margin: 0;", "  color: red;", "}" }), vim.inspect(css))

-- La configuración del proyecto manda.
vim.fn.writefile({ '{ "singleQuote": true, "semi": false }' }, directory .. "/.prettierrc")
local configured = save("config.ts", { 'const nombre: string = "Ana";' })
assert(configured[1] == "const nombre: string = 'Ana'", vim.inspect(configured))
vim.fn.delete(directory .. "/.prettierrc")

-- Con un error de sintaxis no falla el guardado ni se pierde el código.
local broken_source = { "const = ;", "function (" }
local broken = save("roto.js", broken_source)
assert(vim.deep_equal(broken, broken_source), vim.inspect(broken))

-- Idempotente y desactivable con Espacio uf.
local _, buffer = save("ejemplo.js", js)
assert(vim.deep_equal(js, vim.api.nvim_buf_get_lines(buffer, 0, -1, false)), "El formato debe ser idempotente")
vim.g.entorno_formatear_al_guardar = false
local raw = save("sin-formato.js", { "const a='x'" })
assert(vim.deep_equal(raw, { "const a='x'" }), "Espacio uf debe permitir conservar el código sin formatear")
vim.g.entorno_formatear_al_guardar = true

vim.cmd("enew!")
vim.fn.delete(directory, "rf")
print("OK: Prettier al guardar en JS/HTML/CSS, configuración del proyecto, errores de sintaxis, idempotencia y desactivación")
