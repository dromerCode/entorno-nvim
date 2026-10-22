# Decisiones e inventario

## Emmet con la misma tecla de las plantillas (2026-10-22)

Dependencia directa `mattn/emmet-vim`, commit
`92ef2f74f4093edc99db5e9e4cf7e40116a85bd6`, fijado también en lazy-lock.json.
Resuelve abreviaturas HTML/CSS, multiplicación y estructuras anidadas que las
plantillas estáticas no interpretan. Alternativa sencilla: snippets y duplicar
líneas; compensa añadirlo para aprender y escribir HTML con menos pasos.
No añade dependencias transitivas, builds, Node ni servidor LSP.
Fuente e instrucciones revisadas: https://github.com/mattn/emmet-vim.

Se carga solo en HTML/CSS y no instala sus atajos globales. Ctrl+j da prioridad
a una plantilla propia exacta; si no existe, expande Emmet. En línea vacía
conserva el selector de plantillas. Los otros lenguajes conservan mini.snippets,
incluido `clg` en JS/TS. Tab y los saltos Ctrl+l/h no se reasignan.
El plugin se instala con `scripts/instalar-plugins.sh` dentro del estado aislado
del repositorio; no se modifica la configuración activa de Neovim.

Verificación 22/10: `tests/comprobar_emmet.lua` pasa pulsando Ctrl+j mediante
feedkeys: repetición, ids, bloque DAW, script, `!`, `main`, `clg` en JS/TS y
plantilla/CSS Emmet dentro de una regla. Añadida a `scripts/comprobar.sh`.
Núcleo y edición pasan; checkhealth termina sin entradas ERROR, con avisos
de herramientas opcionales, tipos de archivo, depreciación y paquetes.
El sandbox bloquea sockets de Neovim/fzf; núcleo/edición/salud se comprobaron
fuera del sandbox, conservando los directorios aislados del repositorio.

## Objetivos entendidos

El objetivo técnico es construir una configuración Lua modular para Neovim
0.11.4, rápida, mantenible y portable. Debe cubrir progresivamente navegación,
búsqueda, LSP, completado, formato, diagnósticos, Git y Markdown, con versiones
de plugins bloqueadas y degradación razonable cuando falten herramientas.

El objetivo personal es ganar soltura real con Neovim y la terminal, reducir la
dependencia de los cursores y disponer de un flujo reproducible para preparar
exámenes en Markdown con imágenes, tablas y PDF. Los atajos deben resultar
cómodos en teclados de PC y Mac y no es necesario conservar `jk` para salir del
modo de inserción.

## Inventario del 5 de agosto de 2026

### Sistema y repositorio

- Debian GNU/Linux 13.6, arquitectura x86_64.
- Neovim 0.11.4 distribuido como AppImage en `/usr/local/bin/nvim`.
- El repositorio estaba en la rama `main`, sin commits previos.
- La identidad Git local o heredada está completa y no se ha modificado.

En el entorno de diagnóstico el AppImage no puede usar FUSE. Neovim sí responde
al ejecutarlo en modo de extracción temporal mediante
`APPIMAGE_EXTRACT_AND_RUN=1`; esta particularidad debe contemplarse en los
scripts de comprobación sin alterar el sistema.

### Configuración activa

La configuración activa ocupa unos 2,6 MB y parte de la plantilla de LazyVim.
Usa `lazy.nvim`, un lockfile y aproximadamente cuarenta plugins. Incluye extras
para TypeScript, ESLint, Prettier, Tailwind, Python, depuración, Markdown y
servicios de IA. También contiene personalizaciones de transparencia, scroll,
atajos, ortografía y exportación Markdown a PDF.

El flujo Markdown actual invoca Pandoc y WeasyPrint, depende de CSS y plantilla
ubicados fuera de la configuración de Neovim y abre el PDF con `xdg-open`.
WeasyPrint no está disponible actualmente en el `PATH`; por ello el flujo no es
portable ni completamente reproducible en este equipo.

No se inspeccionaron los módulos de IA, tokens, logs, sesiones, archivos de
deshacer ni contenido de estado. El inventario mostró que esas áreas pueden
contener datos sensibles y deben permanecer fuera del proyecto.

### Datos y copia de seguridad

- Datos de Neovim: aproximadamente 618 MB.
- Estado de Neovim: aproximadamente 1,9 MB.
- Caché de Neovim: aproximadamente 76 MB.
- Copia completa histórica bajo `~/copias-seguridad`: 623 MB en el inventario
  inicial.

La copia contiene configuración, datos y estado. No se modificó ni se leyó el
contenido de sus archivos potencialmente sensibles.

### Herramientas disponibles

| Área | Disponible | No disponible en `PATH` |
| --- | --- | --- |
| Base | Git 2.47.3, ripgrep 15.2, fdfind 10.2, fzf 0.60 | - |
| Construcción | GCC 14.2, Make 4.4, CMake 3.31 | Clang |
| Git interactivo | lazygit 0.50 | - |
| JavaScript | Node 22.23.2, npm 10.9.8, Corepack 0.34.6, Prettier 3.6.2 | pnpm, ESLint |
| Python | Python 3.13.5, pipx 1.7.1 | WeasyPrint |
| Markdown/PDF | Pandoc 3.1.11.1, pdfLaTeX, XeLaTeX, LuaLaTeX | Typst |
| Shell | Bash 5.2 | Zsh, Fish, ShellCheck, shfmt |
| Lua | LuaJIT incluido en Neovim | Lua, LuaRocks, StyLua |

Mason conserva ejecutables para Ruff, vtsls, shfmt, StyLua, markdownlint-cli2,
Pyright, Tailwind, Marksman, lua-language-server, Prettier, ESLint LSP y el
adaptador de depuración de JavaScript. Son parte de los datos activos de la
configuración anterior: no deben considerarse una instalación portable ni una
dependencia garantizada del proyecto nuevo.

## Riesgos detectados

1. Los datos y el estado anteriores contienen tokens, sesiones y copias de
   deshacer potencialmente sensibles; nunca deben copiarse al repositorio.
2. El ejecutable AppImage depende de FUSE en ejecución normal dentro de este
   entorno, lo que puede falsear pruebas si no se aísla correctamente.
3. La configuración anterior tiene una superficie de dependencias grande y usa
   actualizaciones flotantes, aunque su lockfile fija los commits actuales.
4. Mason oculta diferencias entre equipos: una herramienta puede funcionar hoy
   sin estar instalada en un sistema nuevo.
5. Los plugins de previsualización Markdown basados en Node pueden ejecutar
   scripts de construcción; deberán justificarse e inspeccionarse antes de
   permitirlos.
6. El flujo de PDF actual mezcla archivos externos, una herramienta ausente y
   `xdg-open`, que no existe en macOS.
7. Atajos con `Alt`, portapapeles y símbolos de Nerd Font pueden variar entre
   terminales, Linux y macOS.

## Arquitectura inicial propuesta

```text
nvim/init.lua
  -> config.options
  -> config.keymaps
  -> config.autocmds
  -> config.lazy
       -> plugins.editor
       -> plugins.search
       -> plugins.lsp
       -> plugins.git
       -> plugins.markdown
```

La propuesta usa `lazy.nvim` directamente, sin LazyVim, con especificaciones
pequeñas por responsabilidad y `lazy-lock.json` versionado. Las opciones,
atajos y autocmds serán nativos. Cada integración externa comprobará el
ejecutable antes de activarse y mostrará un diagnóstico comprensible si falta.

Antes de elegir cada plugin se comparará con la función nativa equivalente. La
primera versión puede usar el explorador y el completado LSP nativos para medir
qué carencias reales justifican dependencias. No se incluirán IA, depuración ni
adornos en el arranque mínimo.

## Plan por fases

1. **Inventario y reglas:** documentar el estado, riesgos, recuperación y forma
   de trabajo. Esta es la fase actual.
2. **Núcleo aislado:** crear `init.lua`, opciones, atajos y autocmds; probar con
   directorios XDG temporales sin tocar la configuración activa.
3. **Gestión de plugins:** incorporar `lazy.nvim`, fijarlo y generar un lockfile;
   documentar el origen y la actualización controlada.
4. **Edición y búsqueda:** añadir solo las dependencias justificadas para
   archivos y búsqueda, aprovechando ripgrep, fdfind y fzf instalados.
5. **Lenguajes:** configurar LSP nativo, completado, diagnósticos y formato con
   detección de herramientas, empezando por Lua, JavaScript/TypeScript y Python.
6. **Git:** integrar indicadores y operaciones frecuentes sin ocultar los
   comandos Git subyacentes.
7. **Markdown y PDF:** crear una muestra con tabla e imagen, comparar opciones
   de previsualización/exportación y fijar un único flujo reproducible.
8. **Portabilidad:** probar Debian, documentar diferencias para CachyOS y macOS,
   Nerd Font, portapapeles y apertura de archivos.
9. **Activación:** preparar instalación y restauración; modificar o enlazar la
   configuración activa solo con aprobación expresa.

## Decisiones pendientes de aprobación

- Empezar con capacidades nativas y añadir plugins solo ante carencias medidas.
- Mantener fuera del alcance inicial la IA y la depuración.

## Fase 2: núcleo aislado

La fase 2 fue aprobada el 5 de agosto de 2026. Se implementó un núcleo que solo
usa la API nativa de Neovim 0.11.4 y carga tres módulos: opciones, atajos y
autocomandos.

El aislamiento usa estas decisiones:

- `XDG_CONFIG_HOME` apunta a la raíz del repositorio para cargar `nvim/init.lua`.
- Datos, estado y caché se guardan bajo `.xdg/`, ignorado por Git.
- `APPIMAGE_EXTRACT_AND_RUN=1` permite probar el AppImage actual cuando FUSE no
  está disponible; otros binarios de Neovim ignoran esta variable.
- Los scripts no consultan ni reutilizan la configuración activa.
- No se carga ningún plugin, gestor de plugins ni ejecutable de Mason.

Los atajos evitan combinaciones `Alt` por sus diferencias entre terminales y
macOS. Tampoco se activa el portapapeles del sistema automáticamente hasta poder
comprobar sus proveedores en cada plataforma.

## Fase 3: plugins mínimos

La fase 3 incorpora `lazy.nvim` directamente, sin LazyVim, y un único plugin
funcional: `fzf-lua`. Ambos quedan fijados por commit en `nvim/lazy-lock.json` y
se descargan bajo el directorio XDG aislado del repositorio.

`fzf-lua` fue elegido porque cubre archivos, texto y buffers sin dependencias
Lua transitivas obligatorias. Usa los ejecutables `fzf` y `rg` ya instalados.
Los iconos se desactivan y no se añaden Nerd Fonts, `bat`, extensiones nativas ni
otros plugins opcionales.

Telescope se descartó en esta fase porque su versión actual requiere Neovim
0.11.7 y `plenary.nvim`, mientras el entorno usa Neovim 0.11.4. También suele
recomendar un sorter nativo adicional, aumentando el alcance y las dependencias.

Lazy tiene deshabilitados LuaRocks, las especificaciones locales de proyecto,
la comprobación automática de actualizaciones y las fuentes de paquetes. Las
actualizaciones deben ser explícitas y conservar el lockfile revisado.

## Fase 7: Markdown y PDF

La fase fija Pandoc a HTML autocontenido y Chromium/Chrome como motor de
impresión. Esta combinación usa un CSS versionado como fuente única de estilo y
funciona con las herramientas ya disponibles en Debian, sin rescatar archivos
de LazyVim ni instalar un plugin Markdown.

El exportador detecta sus dependencias, resuelve imágenes desde el directorio
del documento y genera un PDF A4 con cabeceras, pies, numeración y saltos
controlados. El módulo Lua solo aporta el comando `:MarkdownPdf` y el mapa
`<leader>mp`; el trabajo reproducible permanece en un script independiente de
Neovim. El ejemplo y la prueba funcional cubren títulos, tabla, SVG relativo,
código, emoji y dos páginas.

XeLaTeX y LuaLaTeX se descartaron como ruta principal porque exigirían mantener
otro sistema de estilos. WeasyPrint, Paged.js, Typst y wkhtmltopdf no están
disponibles y no ofrecen una ventaja suficiente para añadir otra dependencia.

## Dashboard IFL

La pantalla de inicio se implementa con un buffer nativo no listado y de solo
lectura. Se abre únicamente en una interfaz sin argumentos ni entrada estándar,
se puede recuperar con `:IFL` y restaura las opciones locales de la ventana al
salir. El logotipo ASCII evita depender de una Nerd Font.

Las acciones reutilizan `fzf-lua` de forma diferida para archivos, texto y
recientes, además de ofrecer archivo nuevo, acceso a la configuración y salida.
No se incorpora un plugin de dashboard porque la API nativa cubre el alcance
completo con menos dependencias y sin ampliar el tiempo de arranque.

## Endurecimiento de tmux y agentes

El flujo usa un socket tmux dedicado para no alterar el servidor personal. El
envío de contexto valida el proceso real del panel, deniega shells y procesos
desconocidos y permite incorporar agentes mediante una lista de identidades y
un lanzador agnóstico para wrappers. El límite se comparte entre Lua y shell,
los temporales tienen permisos privados y una purga acotada, y las rutas
sensibles comunes se bloquean como medida preventiva.

El panel de Neovim conserva una shell al cerrar el editor y las reconexiones no
reconstruyen layouts existentes. La compatibilidad se revisó con sintaxis POSIX
y alternativas GNU/BSD. La suite tmux se validó después también con tmux 3.6b
en macOS Apple Silicon; CachyOS y la suite completa de Neovim en macOS siguen
pendientes.

## Tmux diario: prefijo, ratón y estado

La fase posterior adopta `Ctrl-a` como prefijo por ergonomía y conserva una vía
explícita para enviar la tecla literal mediante `Ctrl-a Ctrl-a`. Se acepta que
esta combinación sustituye temporalmente el «principio de línea» de Readline y
otras acciones propias de aplicaciones mientras tmux espera una orden.

El ratón se activa como apoyo para selección, ventanas, redimensionado y scroll,
sin reemplazar los bindings `h/j/k/l`. La barra de estado muestra únicamente la
sesión, las ventanas y el nombre corto del directorio activo. No se incorporan
TPM, SessionX, Resurrect, Continuum ni integración automática de portapapeles en
esta fase.

Una fase posterior amplía esa base con una barra ASCII propia, todavía sin TPM
ni plugins. `proyecto.sh` registra la raíz canónica en
`@entorno_project_root`; un helper POSIX obtiene desde ella la rama y los cambios
versionados de Git y localiza el agente por `@entorno_role`, no por la posición
del panel. El intervalo de 15 segundos y `--untracked-files=no` limitan el coste
en repositorios grandes a cambio de no señalar archivos nuevos sin seguimiento.
La presentación usa el nombre base del proyecto sin alterar el identificador
real de la sesión y diferencia la ventana activa con una paleta limitada a los
16 colores ANSI. Los índices de ventana facilitan futuros espacios `git`,
`server` o `logs`; los separadores y el estado `AI:-` permanecen en ASCII.
La revisión visual posterior añade corchetes a la ventana activa como fallback
sin color, controla explícitamente los separadores y destaca la hora, sin mover
presentación al helper ni introducir una fuente especial.

## Limpieza visual al lanzar agentes

El ciclo selector → shell → agente se conserva para no alterar el contrato del
transporte de contexto. Después de validar el destino y publicar
`@entorno_agent_command` y `@entorno_agent_process`, `scripts/agente.sh` limpia
el scrollback tmux y la pantalla ANSI inmediatamente antes de `exec`. La
limpieza no afecta al rol, la metadata ni el proceso que valida `<leader>ac`.

## Node 24 LTS

La instalación vigente usa Node `>=24 <25`, en lugar de conservar el límite
histórico de Node 22. Las herramientas LSP no requieren la rama anterior y Node
24 ofrece una base LTS más actual para máquinas nuevas. pnpm continúa fijado por
`packageManager` y los lockfiles; no se instala globalmente.

## Node vendorizado y plataformas docentes

Exigir al alumno un Node 24 del sistema era el principal bloqueo real: Debian 13
no lo trae, Arch es una distribución rodante y no todas las instalaciones
incluyen `corepack`. Para que el mismo repositorio funcione en WSL2, Debian y
Arch sin administrar el sistema, `scripts/instalar-node.sh` descarga Node 24
LTS dentro de `.tools/`, con `SHA-256` publicado por nodejs.org y validación de
rutas del archivo antes de extraer. `scripts/lib/plataforma.sh` concentra la
detección de sistema, distribución, WSL2 y arquitectura, y decide el artefacto
(`linux-x64`, `linux-arm64`, `darwin-arm64`, `darwin-x64`). El Node del sistema
solo se usa como respaldo si no existe artefacto fijado para esa arquitectura.

`scripts/arrancar.sh` antepone ese Node al `PATH` porque los lanzadores de los
servidores LSP invocan `node` por `PATH`. En WSL2 el navegador pasa a ser
opcional: sin WSLg no hay portapapeles X11 y el PDF puede no estar disponible,
pero el editor, tmux, lazygit y Git funcionan. La configuración detecta el
portapapeles de Windows (`win32yank.exe` o `clip.exe`/`powershell.exe`) y el
visor del PDF intenta `wslview` o `explorer.exe` antes de `xdg-open`. La guía
para el alumno vive en [alumno.md](alumno.md).

## Instalador comodo y seguro

`instalar.sh` es el unico comando que necesita el alumno. Clasifica lo que falta
en imprescindible y opcional, descarga sin `sudo` todo lo que vive en el
repositorio y, si falta un paquete del sistema, imprime el comando exacto para
la distribucion detectada. La opcion `--sistema` muestra ese comando, pide
confirmacion por terminal y solo entonces lo ejecuta con `sudo`; nunca instala
paquetes en silencio. `comprobar-requisitos.sh` queda como diagnostico de solo
lectura. Se mantiene la regla de no usar `sudo` sin consentimiento explicito.

## 2026-09-27: productividad y descubrimiento

Se incorporan snippets propios en formato VS Code para HTML y React, sin una
colección externa ni Emmet. Los componentes no importan React por defecto
(runtime JSX moderno); los hooks indican el import necesario. Las plantillas
son editables en `nvim/snippets/`. `rafce` y `rfce` incluyen export default.

Se añade la dependencia directa indent-blankline.nvim, fijada por commit:
representa cada nivel de indentación con una guía de color. La alternativa
mini.indentscope solo representa el bloque activo; no resuelve la visualización
de todos los niveles solicitada. No requiere herramientas externas.

Los pliegues usan Tree-sitter cuando existe parser y la indentación como
alternativa. Arrancan abiertos. La ayuda `Espacio ?` / F1 muestra operaciones
nativas, plantillas, diagnósticos y pliegues sin multiplicar menús principales.

## Docker, formato al guardar y ayuda para el alumnado (2026-09-30)

Se añaden dos dependencias directas en `tools/lsp-docker`, fijadas en su
lockfile y con la misma política pnpm que el resto (`minimumReleaseAge` de 7
días, sin scripts de construcción aprobados):

- `dockerfile-language-server-nodejs` 0.15.0 (MIT): errores y completado de
  instrucciones en Dockerfile. Alternativa sencilla: ninguna nativa.
- `@microsoft/compose-language-service` 1.0.0 (MIT): completado y ayuda en
  `compose.yaml`. No valida todo el esquema; sí completa claves y servicios.

Total de 17 paquetes, ninguno con scripts de instalación.

El formato al guardar, antes descartado, se activa a petición del profesor.
No añade Prettier ni conform.nvim: usa el formateo de los servidores ya
presentes (TypeScript, HTML, CSS, JSON, Docker) y, si existen como paquetes
del sistema, `shfmt` (vía bash-language-server) y `ruff server` para Python.
`Espacio uf` lo desactiva. `shfmt` y `ruff` son opcionales: el instalador SI
los ofrece solo si el gestor de paquetes los tiene.

TypeScript recibe `locale = "es"` para dar sus mensajes en español. ShellCheck,
Pyright y los servidores de Docker no tienen traducción.

Si falta un servidor del perfil, Neovim avisa al abrir ese tipo de archivo:
antes solo lo registraba `:EntornoInfo` y el alumno creía que no había errores.
Los diagnósticos muestran letra en el margen, subrayado simple y el mensaje en
la línea del cursor, porque Windows Terminal y tmux no dibujan undercurl.

Snippets propios para Bash, Python, Dockerfile, Docker Compose y CSS, en el
mismo formato VS Code. `compose*.yaml` se detecta como `yaml.docker-compose`.
El menú `Espacio l` repite `gd`, `K`, `grr`, `grn` y `gra` con nombres claros.

## Perfil único del alumnado y menú al estilo LazyVim (2026-09-30)

Los perfiles `dwec` y `si` se unifican en `alumno`: el coste es de unos
130 MB más en SI y ninguno en rendimiento, porque cada servidor solo arranca
al abrir su tipo de archivo (Tailwind, además, solo si el proyecto lo usa).
Con perfiles separados, lo que faltaba no se notaba como error: simplemente
no se marcaba nada. `dwec` y `si` se siguen aceptando y equivalen a `alumno`.

El menú de `Espacio` toma la organización de LazyVim sin copiar su código:
`b` archivos abiertos, `f` buscar, `g` Git, `l` código, `s` plantillas,
`t` texto (cada entrada muestra su tecla nativa para aprenderla), `r`
ejecutar el archivo, `u` opciones. `Esc` limpia la búsqueda, como en
LazyVim; `Espacio d`, `h` y `q` salen del primer nivel. Los avisos se
limitan a una línea: si no caben, Neovim pide ENTER y se come las teclas.
