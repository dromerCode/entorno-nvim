# LSP y completado nativo

## Validación HTML del marcado

El servidor HTML aporta completado, formato y operaciones de etiquetas, pero
no comprueba por sí solo todo el marcado. `config.html_validation` añade
`html-validate` 11.16.2, instalado y fijado en `tools/lsp-web` con Node 24.
En la misma carpeta se fija `prettier` 3.9.10 para el formato al guardar
(ver `docs/decisiones.md`).
Lo reciben tanto el instalador completo como el del alumnado. Para actualizar
una copia existente: `./scripts/actualizar.sh`; para reinstalar solo estas
herramientas: `./scripts/instalar-lsp-web.sh`.

En archivos `.html`, el análisis se programa 400 ms después de editar y también
al abrir o guardar. Usa el contenido del buffer por stdin, sin archivos
temporales ni servicios externos. El margen muestra E, el texto se subraya y
`gl` abre el diagnóstico; `[d` / `]d` recorren los resultados. La presentación
respeta la opción general de no actualizar diagnósticos durante inserción:
al salir con Esc se ven los resultados. Corregir el marcado retira el error.

Comprueba atributos desconocidos como `idddd`, ids/atributos duplicados,
etiquetas desconocidas como `footerr`, orden de cierres y contenido permitido.
`input`, `img` y los demás elementos vacíos no pueden llevar cierre explícito.
Acepta fragmentos sin doctype/head y elementos personalizados con guion. No
impone comillas, sangría ni otras preferencias de estilo. No analiza JSX,
Vue ni plantillas de otros lenguajes con estas reglas HTML.

El adaptador usa una configuración fija, sin cargar código de configuración
del proyecto editado. Descarta respuestas de versiones anteriores del buffer,
cancela procesos pendientes y convierte offsets UTF-16 a columnas UTF-8 para
que los subrayados no se desplacen tras tildes o emojis. Los mensajes de la
dependencia se conservan en su idioma original. La regla de atributos
desconocidos está marcada experimental por el proveedor; puede tener falsos
positivos o faltar metadatos. Referencia: [regla no-unknown-attributes](https://html-validate.org/rules/no-unknown-attributes.html).

Prueba aislada: `tests/comprobar_html_validation.lua`, incluida en
`scripts/comprobar.sh`. Usa texto sintético y verifica diagnósticos antes de
guardar, desaparición al corregir, posición tras Unicode y respuestas antiguas.

## Responsabilidades

Neovim 0.12.4 aporta el cliente LSP, los diagnósticos, la navegación, las
acciones de código, el formato, el completado y la expansión de snippets. Los
módulos `config.lsp` y `config.completion` organizan esas APIs nativas.

`nvim-lspconfig` v2.9.0 se fija en el commit
`f6738ef65dabade340b473d4ff2a1ad3352c10e7`. Solo aporta archivos `lsp/*.lua`
con comandos, tipos de archivo, marcadores de raíz y ajustes iniciales. No es
el cliente LSP, no instala servidores y no gestiona el completado. No se usa la
API antigua `require("lspconfig")`.

`config.lsp.enable(nombre, ajustes)` combina el catálogo con ajustes propios
mediante `vim.lsp.config()` y activa el servidor con `vim.lsp.enable()`. Están
habilitados `lua_ls`, `ts_ls`, `html`, `cssls`, `jsonls` y `tailwindcss`; sus
procesos solo arrancan al abrir un tipo de archivo compatible y encontrar una
raíz válida. Pyright está habilitado con el mismo mecanismo para Python.

## Mapas de Neovim 0.12

Neovim ya define estos mapas globales y no se duplican:

| Mapa | Acción |
| --- | --- |
| `gra` | Acción de código |
| `gri` | Ir a la implementación |
| `grn` | Renombrar símbolo |
| `grr` | Mostrar referencias |
| `grt` | Ir a la definición de tipo |
| `grx` | Ejecutar code lens |
| `gO` | Mostrar símbolos del documento |
| `Ctrl-S` en insertar | Mostrar ayuda de firma |

Cuando un servidor se conecta, Neovim también configura `K` para mostrar la
documentación del símbolo, `Ctrl-]` para ir a una definición y `gq` para
formatear el rango cuando el servidor lo permite.

El entorno ajusta `K` para abrir esa información en una ventana flotante con
borde y texto envuelto. En TypeScript, sitúe el cursor sobre el nombre de una
variable para ver el tipo que infiere el servidor.

Por ejemplo, CryptoJS declara que `AES.decrypt()` devuelve
`CryptoJS.lib.WordArray`, no `string[]`. Puede dejar que TypeScript lo infiera o
anotarlo explícitamente; para obtener texto UTF-8:

```ts
const bytes: CryptoJS.lib.WordArray = CryptoJS.AES.decrypt(texto, clave)
const textoOriginal: string = CryptoJS.enc.Utf8.stringify(bytes)
```

`Utf8.stringify` recibe el `WordArray` y devuelve `string`. Para consultar el
tipo inferido con `K`, coloque el cursor sobre `bytes` o sobre la llamada; sobre
`CryptoJS.AES` verá la documentación del helper, no el tipo devuelto.

El proyecto añade solo mapas locales al buffer conectado:

| Mapa | Acción |
| --- | --- |
| `gd` | Ir a la definición |
| `gD` | Ir a la declaración |
| `<leader>lf` | Formatear el buffer completo |

`gd` es una alternativa directa a la navegación mediante `Ctrl-]`. Los mapas
locales no afectan a buffers sin un cliente LSP.

## Completado

Para generar JSDoc, escriba `/**` en una línea justo encima de la función y
pulse `Enter`. El servidor debe estar conectado al archivo. Sin servidor,
`Enter` mantiene la inserción normal de una línea nueva. También puede usar
`Espacio l j` sobre la función o `docfn` + `Ctrl+j` encima de ella.
La comprobación `tests/comprobar_jsdoc.lua` reproduce las teclas reales en un
Neovim hijo con TypeScript y comprueba también el funcionamiento de Enter normal.

Al conectarse un cliente que anuncie `textDocument/completion`, se llama a
`vim.lsp.completion.enable()` con `autotrigger = true`. Los caracteres que
abren automáticamente el menú dependen de cada servidor.

| Tecla | Acción nativa |
| --- | --- |
| `Ctrl-Space` | Solicitar completado LSP expresamente |
| `Ctrl-X Ctrl-O` | Usar el completado LSP mediante `omnifunc` |
| `Tab` / `Shift-Tab` | Recorrer candidatos cuando el menu esta visible |
| `Ctrl-N` / `Ctrl-P` | Recorrer candidatos como alternativa nativa |
| `Enter` / `Ctrl-Y` | Aceptar el candidato seleccionado |
| `Ctrl-E` | Cerrar el menú |

`completeopt` usa `menu`, `menuone`, `noselect` y `popup`. Esto evita aceptar
una opción accidentalmente y permite mostrar su documentación. Neovim puede
aplicar imports, ediciones adicionales y snippets al aceptar un elemento; no
se instala un motor de snippets externo. Fuera del menú, `Tab` y `Shift-Tab`
conservan la indentación normal o saltan entre posiciones de un snippet nativo
activo; `Enter` conserva la inserción de una línea nueva.

## Diagnósticos durante la escritura

Los diagnósticos muestran el signo en el margen y subrayan el código afectado;
no imprimen mensajes largos al final de la línea. `gl` abre los diagnósticos de
la línea actual; `Espacio l d` abre los del archivo completo. Las ventanas
flotantes ajustan el texto a un máximo de 80 columnas y 20 líneas. `[d` y `]d`
recorren los problemas y muestran su detalle. `K` consulta el tipo y la
documentación del símbolo bajo el cursor cuando el servidor LSP lo proporciona.
Se usa `update_in_insert = false` para que los mensajes no salten mientras se
escribe; se actualizan al volver al modo normal. Esta presentación se aplica
por igual a Bash, Python, JavaScript y los demás servidores activos.

## Servidores web activos

| Configuración | Lenguajes | Ejecutable |
| --- | --- | --- |
| `ts_ls` | JavaScript, TypeScript, JSX y TSX | `typescript-language-server --stdio` |
| `html` | HTML | `vscode-html-language-server --stdio` |
| `cssls` | CSS, SCSS y Less | `vscode-css-language-server --stdio` |
| `jsonls` | JSON y JSON con comentarios | `vscode-json-language-server --stdio` |
| `tailwindcss` | HTML, CSS, JavaScript/JSX y TypeScript/TSX en proyectos Tailwind | `tailwindcss-language-server --stdio` |

Los comandos usan rutas absolutas bajo `tools/lsp-web/node_modules/.bin`; no
dependen del `PATH` global. `nvim-lspconfig` sigue aportando tipos de archivo,
raíces de proyecto, opciones iniciales y comandos específicos de TypeScript.
En HTML se conservan los modos embebidos para JavaScript y CSS.

Para `ts_ls`, la raíz se detecta por este orden: lockfile del gestor de
paquetes, `package.json` y `.git`. Un proyecto sencillo con `package.json` pero
sin lockfile queda aislado correctamente; los monorepos con lockfile conservan
la raíz común. Los proyectos Deno siguen excluidos de `ts_ls`.

El perfil `si` activa Bash Language Server 5.6.0 desde
`tools/lsp-bash/node_modules/.bin`, instalado con
`scripts/instalar-lsp-bash.sh`. Usa Node 24 local, no instala paquetes globales
y puede aprovechar ShellCheck cuando existe. Zsh, Docker y Kubernetes quedan
para una fase posterior. Tampoco existe format-on-save:
`<leader>lf` sigue siendo una acción manual.

## Python: Pyright frente a BasedPyright

El 10 de agosto de 2026 se compararon Pyright 1.1.411 y BasedPyright 1.39.9.
Ambos están mantenidos, usan el núcleo de análisis de Pyright y ofrecen
diagnósticos, completado, hover, definición, referencias y rename. Ambos siguen
la evolución del tipado de Python y son aptos para código moderno.

| Criterio | Pyright | BasedPyright |
| --- | --- | --- |
| Mantenimiento y estabilidad | Proyecto original de Microsoft, releases frecuentes y amplia adopción | Fork activo que integra upstream y publica releases frecuentes |
| Diagnóstico | Rápido, estable y configurable | Añade reglas, correcciones y avisos que upstream no incluye |
| Navegación y completado | Cubre todas las operaciones LSP requeridas | Cubre las mismas y añade algunas funciones de Pylance |
| Ruido inicial | Permite elegir `basic` | Su valor predeterminado `recommended` habilita todas las reglas y es deliberadamente más estricto |
| Instalación aislada | Paquete npm oficial; requiere Node | PyPI recomendado o npm; el paquete PyPI incorpora la parte Node mediante `nodejs-wheel` |
| Dependencias y seguridad | Una dependencia opcional, `fsevents` en macOS; release firmada y licencia MIT | Paquete PyPI MIT, publicado con Trusted Publishing; su página actual muestra un mantenedor |

Para scripts, docencia y proyectos generalistas se elige **Pyright 1.1.411**.
BasedPyright es una alternativa sólida si más adelante se desea una política de
tipado más exigente, pero sus valores predeterminados no encajan tan bien con
el objetivo de evitar ruido a principiantes. No hay diferencia material entre
ambos para las operaciones de edición requeridas.

La configuración propia mantiene deliberadamente estos valores:

- `typeCheckingMode = "basic"`: detecta incompatibilidades sencillas y nombres
  indefinidos sin exigir anotaciones exhaustivas;
- `diagnosticMode = "openFilesOnly"`: limita el trabajo y los avisos cotidianos
  a los archivos abiertos;
- `autoSearchPaths = true`: reconoce disposiciones habituales como `src`;
- `useLibraryCodeForTypes = true`: aprovecha el código de bibliotecas cuando no
  hay stubs disponibles.

Un `pyrightconfig.json` o la sección `[tool.pyright]` de un proyecto puede
especializar estos valores. El catálogo conserva también
`:LspPyrightSetPythonPath /ruta/al/.venv/bin/python` para seleccionar
manualmente un entorno virtual en el buffer actual. No se fija la versión de
Python de los proyectos desde Neovim.

Fuentes oficiales consultadas:

- `https://github.com/microsoft/pyright/releases/tag/1.1.411`;
- `https://github.com/microsoft/pyright/blob/main/docs/configuration.md`;
- `https://github.com/microsoft/pyright/blob/1.1.411/packages/pyright/package.json`;
- `https://docs.basedpyright.com/latest/benefits-over-pyright/better-defaults/`;
- `https://docs.basedpyright.com/latest/installation/command-line-and-language-server/`;
- `https://pypi.org/project/basedpyright/1.39.9/`.

## LuaLS para la configuración de Neovim

LuaLS 3.19.0 se ejecuta mediante una ruta absoluta, sin Mason y sin depender
del `PATH`. `lua_ls` se configura y activa con las mismas funciones nativas que
los servidores web: `vim.lsp.config()` y `vim.lsp.enable()`.

Los ajustes propios de Neovim son deliberadamente acotados:

- el runtime es `LuaJIT` y las rutas de módulos son `lua/?.lua` y
  `lua/?/init.lua`;
- `vim` se declara como global conocido;
- `workspace.library` contiene solo el `$VIMRUNTIME` del Neovim que está en
  ejecución, no todo el `runtimepath` ni directorios del sistema;
- la raíz procede de los marcadores del catálogo, incluida `.git`;
- se respetan `.gitignore` y se excluyen `.git`, `.xdg`, `.backups` y
  `node_modules` del diagnóstico del workspace;
- la detección automática de addons de terceros queda desactivada para evitar
  preguntas y ajustes implícitos.

Los logs se escriben dentro del estado XDG aislado del repositorio, no junto al
binario instalado. El catálogo mantiene sus capacidades base, como code lens e
inlay hints; los ajustes anteriores solo especializan el entorno de Neovim.

## Activación selectiva de Tailwind

`tailwindcss` está habilitado en Neovim, pero su proceso solo arranca cuando
`root_dir` confirma al menos una evidencia de proyecto Tailwind:

- `package.json` declara `tailwindcss` en dependencias directas, de desarrollo,
  opcionales o de pares;
- existe `tailwind.config.js`, `.cjs`, `.mjs`, `.ts`, `.cts` o `.mts`;
- el buffer CSS abierto contiene `@import "tailwindcss"`, una directiva
  `@tailwind` o una referencia `@config`.

Un proyecto HTML, JSX o TSX normal no satisface ninguna de estas condiciones y
no inicia el servidor. La detección lee `package.json` con el decodificador JSON
de Neovim; no usa búsquedas de texto ambiguas.

Para Tailwind v4 CSS-first, `before_init` localiza hasta veinte hojas de entrada
CSS dentro de la raíz, omitiendo `.git`, `node_modules`, salidas de compilación
y cachés habituales. Las pasa al ajuste oficial
`tailwindCSS.experimental.configFile` con un selector limitado al directorio de
cada entrada. Si existe una configuración clásica, no se fuerza este ajuste y
el servidor conserva la detección nativa de Tailwind v3/v4.

El recorrido tiene límites de 2.000 entradas y veinte hojas CSS para evitar que
el arranque examine indefinidamente un monorepo grande. Si un proyecto v4 tiene
varias entradas fuera de esos límites, puede necesitar una configuración
explícita futura.

Tailwind convive con `ts_ls`, `html` y `cssls`: cada servidor mantiene su propio
ámbito. Neovim presenta los colores mediante su capacidad nativa
`textDocument/documentColor`; no se añadió un plugin de Tailwind.

## Versiones y decisión TypeScript

El 7 de agosto de 2026 se verificaron en el registro oficial estas versiones
estables: pnpm 11.20.0, TypeScript 7.0.2, typescript-language-server 5.3.0 y
vscode-langservers-extracted 4.10.0. La publicación oficial marca
`@tailwindcss/language-server` 0.16.0 como la versión estable más reciente.

El entorno fija pnpm 11.18.0 porque 11.20.0 llevaba solo cuatro días publicado
y la política exige siete días de antigüedad. Se fija TypeScript 6.0.3 porque
`typescript-language-server` 5.3.0 envuelve la API de `tsserver`; TypeScript 7
es una implementación nativa distinta y ya no ofrece esa API estable. Migrar
al servidor nativo de TypeScript 7 requiere una evaluación independiente.

Fuentes oficiales consultadas:

- `https://registry.npmjs.org/pnpm/11.18.0`;
- `https://registry.npmjs.org/typescript/6.0.3`;
- `https://registry.npmjs.org/typescript-language-server/5.3.0`;
- `https://registry.npmjs.org/vscode-langservers-extracted/4.10.0`;
- `https://registry.npmjs.org/@tailwindcss/language-server/0.16.0`;
- `https://github.com/tailwindlabs/tailwindcss-intellisense/releases/tag/v0.16.0`;
- `https://github.com/tailwindlabs/tailwindcss-intellisense#tailwindcssexperimentalconfigfile`;
- `https://github.com/typescript-language-server/typescript-language-server/releases/tag/v5.3.0`;
- `https://www.typescriptlang.org/docs/handbook/release-notes/typescript-6-0.html`.

## Versión y auditoría de LuaLS

El 9 de agosto de 2026, la versión estable actual es LuaLS 3.19.0, publicada el
7 de agosto como release no preliminar del repositorio oficial
`LuaLS/lua-language-server`. Para esta máquina `x86_64` se usa el artefacto
oficial `lua-language-server-3.19.0-linux-x64.tar.gz`, de 3.665.023 bytes, con
SHA-256 publicado por GitHub:

```text
624ae8dd3bfbd5c2ee3ccf2f3547d33aeefa209971cce8c11d48f69fc1ec065a
```

El tarball se revisó antes de instalarlo: no contiene rutas absolutas, escapes
`..`, enlaces ni scripts shell, Python o Perl. Solo
`bin/lua-language-server` es ejecutable; el resto son módulos Lua, metadatos de
tipos, traducciones, changelog y licencia. El binario es un ELF de 64 bits para
x86-64, enlazado dinámicamente solo con el cargador de glibc, `libc`, `libm`,
`libpthread` y `libdl`. No necesita Node, Java, Python ni un paso de build.

La procedencia es el release oficial, generado y subido por GitHub Actions del
proyecto. El archivo incluye la licencia MIT de LuaLS, copyright desde 2018.
No se incorpora una dependencia al repositorio: el servidor es una herramienta
externa directa y reemplaza la alternativa de Mason, que permanece excluida.

Fuentes oficiales consultadas:

- `https://github.com/LuaLS/lua-language-server/releases/tag/3.19.0`;
- `https://api.github.com/repos/LuaLS/lua-language-server/releases/latest`;
- `https://github.com/LuaLS/lua-language-server`;
- `https://luals.github.io/#neovim-install`;
- `https://luals.github.io/wiki/settings/`.

## Instalación reproducible

La configuración vigente adopta Node `>=24 <25` LTS. El instalador descarga
Node 24.21.0 verificado dentro de `.tools/` (`scripts/instalar-node.sh`) y usa
su Corepack; no se ejecuta `corepack enable`, no se instala pnpm globalmente y
no se cambia el `PATH` de forma permanente. Los instaladores LSP anteponen ese
Node vendorizado cuando existe y solo recurren al Node del sistema si no hay
artefacto fijado para la arquitectura.

```sh
./scripts/instalar-node.sh
./scripts/instalar-lsp-web.sh
./scripts/instalar-lsp-python.sh
```

El comando para recrear esta subfase es:

```sh
cd /ruta/al/entorno-nvim
NVIM_XDG_ROOT="$PWD/.xdg/0.12.4" ./scripts/instalar-lsp-web.sh
```

No requiere `corepack enable`, pnpm global, Mason ni cambios en `PATH`. La orden
descarga la versión de pnpm fijada, exige el lockfile sin cambios y recrea
`tools/lsp-web/node_modules` usando el almacén aislado indicado.

El manifiesto fija versiones exactas y el campo `packageManager` fija pnpm
11.18.0 junto con el SHA-512 del artefacto. El lockfile conserva todas las
versiones transitivas e integridades. Corepack se descarga bajo
`.xdg/0.12.4/corepack`, el almacén está en `.xdg/0.12.4/pnpm/store` y los
enlaces ejecutables quedan en `tools/lsp-web/node_modules/.bin`.

Pyright se instala de forma independiente bajo
`tools/lsp-python/node_modules/.bin`. Su manifiesto fija Pyright 1.1.411 y el
mismo pnpm 11.18.0; el lockfile registra versiones e integridades. El script
invoca esa versión de pnpm explícitamente, usa el mismo almacén XDG aislado y
exige el lockfile congelado. No usa Mason, `sudo`, npm global ni modifica el
`PATH`.

El paquete oficial de Pyright no declara ciclos `preinstall`, `install` ni
`postinstall`; sus órdenes `build` y `prepack` son de desarrollo/publicación y
no se ejecutan al instalar el tarball. La única dependencia de ejecución es
`fsevents 2.3.3`, opcional y limitada a macOS. Su build queda denegado en
`pnpm-workspace.yaml`: Pyright conserva el watcher portable de Node. El
lockfile y la política de pnpm bloquean fuentes exóticas, verifican el almacén
y rechazan builds no revisados. `pnpm audit --audit-level low` no encontró
vulnerabilidades conocidas el 10 de agosto de 2026.

La instalación y las pruebas funcionales se han validado en Debian 13. El
diseño usa Node, Corepack y rutas POSIX razonables para CachyOS y macOS, pero no
se afirma una validación real en esos sistemas. En macOS se omite el build
opcional de `fsevents`, por lo que Pyright usará el mecanismo portable de
observación de archivos.

Para actualizar Pyright hay que comprobar el release oficial y su manifiesto,
cambiar la versión exacta en `tools/lsp-python/package.json`, ejecutar desde la
raíz `corepack pnpm@11.18.0 --dir tools/lsp-python install
--no-frozen-lockfile`, revisar el nuevo `pnpm-lock.yaml` y repetir las pruebas
LSP. Para recrear la versión ya fijada basta con ejecutar
`./scripts/instalar-lsp-python.sh`.

La política de `pnpm-workspace.yaml`:

- retrasa siete días cualquier versión nueva;
- falla si falta la fecha de publicación;
- verifica integridad y contenido del almacén;
- impide fuentes transitivas Git o tarballs arbitrarios;
- considera error cualquier build no revisado;
- deniega expresamente el `postinstall` informativo de `core-js`.

Los tarballs directos se inspeccionaron antes de instalar y todas sus rutas
quedaban bajo `package/`. Ninguno declara `preinstall`, `install` o
`postinstall`; `typescript-language-server` conserva un `prepare` de desarrollo
que no se ejecuta para el artefacto ya compilado. La inspección transitoria con
`--ignore-scripts` confirmó que `core-js` era el único ciclo instalable. La
auditoría del lockfile no encontró vulnerabilidades conocidas en esta fecha.

`@tailwindcss/language-server` 0.16.0 exige Node `>=18`, por lo que es compatible
con Node 22.23.2. Su artefacto publicado no tiene dependencias de ejecución ni
scripts de ciclo de instalación: distribuye el servidor ya compilado y varios
watchers nativos para las plataformas soportadas. Sus scripts `build`, `test` y
`clean` son solo de desarrollo y no se ejecutan al instalar el tarball. Se
verificó su procedencia publicada, integridad SHA-512 y contenido antes de
añadirlo. `pnpm audit --audit-level low` no encontró vulnerabilidades conocidas
en el entorno combinado el 7 de agosto de 2026.

La prueba v4 usa `tailwindcss` 4.3.3 como dependencia exacta de un fixture
independiente. Ese paquete tampoco declara dependencias transitivas ni scripts
de instalación. Su manifiesto y lockfile viven en
`tests/fixtures/lsp-tailwind-v4`; `node_modules` permanece fuera de Git.

LuaLS se instala por separado:

```sh
./scripts/instalar-luals.sh
```

El script solo admite por ahora Linux x86_64, la plataforma auditada. Descarga
por HTTPS el artefacto exacto, comprueba el SHA-256 antes de extraerlo, rechaza
rutas inseguras, valida contenido, versión y hash del ejecutable, y mueve el
resultado terminado a `~/.local/opt/lua-language-server-3.19.0`. No usa
`sudo`, Mason, gestores globales ni modifica el `PATH`. Si la ruta ya existe,
solo la acepta cuando los metadatos y el binario coinciden.

Actualizar LuaLS requiere revisar primero el nuevo release y sus hashes,
cambiar las constantes del instalador y la ruta predeterminada del runner, y
repetir la prueba funcional completa. No se usa una URL flotante `latest` para
instalar.

## Comprobación funcional

`tests/comprobar_lsp_lua.lua` usa un fixture Lua real y comprueba conexión,
raíz, capacidades, completado sobre `vim.`, hover de la API de Neovim,
definición, navegación con `gd`, diagnósticos, referencias y rename. Los
cambios de completado y rename permanecen en memoria y no escriben el fixture.

`tests/comprobar_lsp_python.lua` abre un proyecto Python 3.13 con un módulo
local y comprueba conexión, raíz, imports, capacidades, definición, hover,
referencias, rename, completado de atributos, un error sencillo de tipos y una
variable indefinida. Confirma además que solo Pyright se conecta al buffer; la
suite conserva después las pruebas reales de LuaLS, `ts_ls`, HTML/CSS/JSON y
Tailwind. Las ediciones de completado y rename permanecen en memoria.

`tests/comprobar_lsp_web.lua` abre fixtures reales JS, TS, JSX, TSX, HTML, CSS y
JSON. Comprueba conexión, diagnósticos, definición, `gd`, hover, referencias,
rename, completado, disparadores automáticos, `Ctrl-Space`, auto-imports y la
capacidad nativa de snippets. Los cambios de rename y completado no se escriben
en los fixtures.

Neovim anuncia soporte de snippets y usa `vim.snippet` cuando un servidor los
entrega. No todos los elementos de completado son snippets; por ejemplo, el
servidor HTML devuelve algunas etiquetas como texto plano. No se instala ningún
motor externo.

`tests/comprobar_tailwind.lua` verifica raíces por dependencia, configuración
clásica y CSS-first v4. En un proyecto v4 real comprueba HTML, JSX, TSX y CSS;
coexistencia con `ts_ls`, `html` y `cssls`; completado de clases, hover,
diagnósticos de conflicto, colores y activación del color nativo. El fixture web
sin Tailwind confirma que el servidor no arranca fuera de su ámbito.

## Lenguajes pendientes

- Bash: `bash-language-server` 5.6.0 se evaluó el 9 de agosto de 2026, pero no
  se instaló. `pnpm audit --audit-level low` detectó tres vulnerabilidades altas
  en la dependencia transitiva `minimatch 10.0.1`, introducida mediante
  `bash-language-server > editorconfig > minimatch`. No se añadieron overrides
  ni se forzó otra versión; se reevaluará cuando el paquete oficial actualice
  sus dependencias.

No hay configuración activa para Bash. Python queda cubierto por Pyright.

## Reversión

La instalación no toca ubicaciones globales. Para revertir LuaLS se deshabilita
`lua_ls` y se retira manualmente
`~/.local/opt/lua-language-server-3.19.0`; esa eliminación está fuera del
repositorio y debe confirmarse expresamente. Los logs aislados bajo
`.xdg/0.12.4/state/nvim/luals` son reproducibles.

Para revertir los servidores web se deshabilitan
las cinco configuraciones correspondientes de `config.lsp`, se retiran
`tools/lsp-web/node_modules` y `tests/fixtures/lsp-tailwind-v4/node_modules` y,
si no se usa para otra fase, se retiran `.xdg/0.12.4/corepack` y
`.xdg/0.12.4/pnpm`. Los tres archivos reproducibles de `tools/lsp-web` permiten
recrear el entorno después.

Para desinstalar Pyright se deshabilita `pyright` en `config.lsp` y se retira
`tools/lsp-python/node_modules`. No queda ningún paquete global. El manifiesto,
la política pnpm y el lockfile pueden mantenerse para reinstalarlo después o
retirarse junto con la configuración si la decisión se revierte.
