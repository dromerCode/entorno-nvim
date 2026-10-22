local root = vim.env.ENTORNO_NVIM_ROOT
require("lazy").load({ plugins = { "mini.nvim" } })
for _, name in ipairs({ "html", "cssls", "ts_ls" }) do vim.lsp.enable(name, false) end

local function expand(ft, abbreviation)
  vim.cmd("enew!")
  vim.bo.filetype = ft
  -- Evitar que un LSP asíncrono cambie el menú durante esta prueba de teclas.
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
    vim.lsp.buf_detach_client(0, client.id)
  end
  if ft == "css" then
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { ".demo {", "  " .. abbreviation, "}" })
    vim.api.nvim_win_set_cursor(0, { 2, 0 })
  else
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { abbreviation })
  end
  vim.fn.feedkeys(vim.api.nvim_replace_termcodes("A<C-j><Esc>", true, false, true), "xt")
  vim.wait(30)
  return table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
end

assert(expand("html", "p*5") == table.concat({ "<p></p>", "<p></p>", "<p></p>", "<p></p>", "<p></p>" }, "\n"))
assert(expand("html", "p#average") == '<p id="average"></p>')
local numbered = expand("html", "p#nota$*5")
for i = 1, 5 do assert(numbered:find('<p id="nota' .. i .. '"></p>', 1, true)) end
local main = expand("html", "main>h1{Notas de 2.º DAW}+p#average+p#passed+p#best+ul#student-list")
for _, part in ipairs({ "<main>", "<h1>Notas de 2.º DAW</h1>", '<p id="average"></p>',
  '<p id="passed"></p>', '<p id="best"></p>', '<ul id="student-list"></ul>', "</main>" }) do
  assert(main:find(part, 1, true), "Falta " .. part .. " en " .. main)
end
assert(expand("html", "script[type=module src=/src/main.ts]") == '<script type="module" src="/src/main.ts"></script>')
assert(expand("html", "!"):find('<html lang="es">', 1, true), "Debe conservar HTML5 propio")
assert(expand("html", "main"):find("<main>contenido</main>", 1, true), "Debe conservar snippet main")
for _, ft in ipairs({ "javascript", "typescript" }) do
  assert(expand(ft, "clg"):find("console.log(", 1, true), "Debe conservar clg en " .. ft)
end
local margin = expand("css", "m10")
assert(margin:match("margin:%s*10px;"), margin)
assert(expand("css", "centrar"):find("display: flex;", 1, true), "Debe conservar plantilla CSS")
assert(vim.fn.maparg("<Tab>", "i", false, true).desc == "Completado siguiente o Tab")
local plugin = require("lazy.core.config").plugins["emmet-vim"]
local lock = vim.json.decode(table.concat(vim.fn.readfile(root .. "/nvim/lazy-lock.json"), "\n"))
assert(lock["emmet-vim"].commit == plugin.commit)
assert(plugin.build == nil and plugin.dependencies == nil)
assert(vim.g.user_emmet_install_global == 0)
print("OK: Ctrl+j Emmet HTML/CSS, bloque DAW, snippets HTML/CSS y clg JS/TS")
