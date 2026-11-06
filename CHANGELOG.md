# Changelog

## Sin publicar

- git-delta como mejora opcional de lazygit: integración local para Neovim/tmux,
  aviso de requisito y oferta en instaladores sin bloquear si falta.

- Markdown largo: la ventana docs sitúa la lectura al principio, usando el modo
  de desplazamiento de tmux y sin paginador externo.
- TypeScript/TSX: el formateador LSP ya instalado inserta los puntos y coma
  sintácticos al guardar, además de ajustar la sangría. Espacio uf lo desactiva.

- Lectura Markdown con mdcat: Espacio m r abre el archivo guardado en una ventana
  tmux docs reutilizable; Espacio m d permite elegir documentación del proyecto.
  r recarga y q cierra y devuelve el foco al editor. Disponible en todos los
  perfiles, sin paginador ni instalación automática; no altera el flujo PDF.

- `entorno-dev .` respeta la carpeta actual aunque sea una subcarpeta de un
  repositorio Git. Antes subía a su raíz y podía reutilizar la sesión de otro
  ejercicio. Las rutas explícitas tienen sesión propia; el selector conserva
  la búsqueda de repositorios. Documentado el alias que transmite argumentos.
- Validación HTML local con html-validate 11.16.2: atributos mal escritos,
  ids repetidos, etiquetas desconocidas y cierres incorrectos. Diagnósticos
  automáticos incluso sin guardar, visibles con `gl`, sin analizar estilo ni
  exigir documento completo a un fragmento. Incluida en el instalador web.
- Emmet en HTML/CSS con `Ctrl+j`, compartido con las plantillas existentes.
  `clg` en JS/TS y `!` en HTML conservan su expansión. Plugin fijado por commit,
  sin Node ni servidor adicional. Tab mantiene su comportamiento.
- **Perfil único del alumnado**: `instalar-alumno.sh` instala web, Bash,
  Python y Docker sin preguntar. `--perfil dwec`/`si` se aceptan y equivalen.
- Menú de `Espacio` reorganizado al estilo LazyVim: `b` archivos abiertos,
  `t` texto y edición (con la tecla nativa entre paréntesis), `r` ejecutar
  el archivo (Bash, Python, JS, TS) en la terminal de abajo. `Esc` limpia la
  búsqueda; salen del menú `Espacio d`, `h` y `q` (ahora `Espacio t d`).
- WSL: el pegado desde el portapapeles de Windows ya no deja `^M` (se quitan
  los `\r`, receta de `:help clipboard-wsl`).
- Comentar como en VS Code con `Ctrl+/` (línea o selección); `Espacio t c`
  también en modo visual. El menú ajusta su ancho y no corta descripciones.
- Avisos cortos para que Neovim no pida ENTER y no se coma teclas.

- Reinstalar tras mover o borrar la carpeta del repositorio ya no falla:
  el comando `entorno-dev` roto se redirige a la copia actual con un aviso.
  Si apunta a otra copia existente, se pregunta antes de cambiarlo.
- Si el comando `entorno-dev` no se puede actualizar, la instalación termina
  con un aviso y la alternativa `./bin/entorno-dev`, no con un error genérico.
- `instalar-alumno.sh` sin opciones muestra un menú (1 = DWEC, 2 = SI),
  recuerda la elección y la propone con Enter al actualizar. `entorno-dev`
  usa ese perfil por defecto.
- El instalador de alumno pregunta antes de instalar paquetes del sistema que
  falten, sin necesidad de `--sistema`; `--sin-sistema` lo impide.
- Mensajes más claros ante opciones erróneas, ejecución como root o falta de
  paquetes, con el comando exacto para continuar.
- `scripts/actualizar.sh`: corrige finales CRLF, restaura `lazy-lock.json`,
  ofrece cerrar sesiones antiguas, hace `git pull --ff-only` y reinstala con
  el perfil recordado.
- Ortografía en español e inglés (`spelllang=es,en`) en Markdown, texto y
  commits; diccionario de Neovim verificado por SHA-256, sin hunspell.
  Faltas en rojo (visibles en WSL y tmux) y menú `Espacio o` (corregir,
  siguiente, añadir, activar).
- Docker: errores y completado en Dockerfile y `compose.yaml` en todos los
  perfiles (servidores fijados en `tools/lsp-docker`).
- Formato automático al guardar (TS, JS, HTML, CSS, JSON, Docker; Bash con
  shfmt y Python con ruff si están instalados). `Espacio uf` lo alterna.
- Mensajes de TypeScript/JavaScript en español.
- Snippets para Bash (20), Python (19), Dockerfile (9), Compose (10) y CSS (9).
- `Espacio s`: lista de plantillas del lenguaje con buscador, sin recordar prefijos.
- Menú `Espacio l`: definición, documentación, usos, renombrar y arreglos.
- Aviso visible al abrir un archivo cuyo servidor no está instalado.
- El instalador SI ofrece `shfmt` y `ruff` como recomendados opcionales.
- `Ctrl-a Q` y `actualizar.sh` cierran Neovim de forma ordenada antes de
  cerrar la sesión (preguntan si hay cambios sin guardar). Los swap de un
  Neovim que ya no existe se resuelven sin la pantalla «Found a swap file»:
  se borran si no hay cambios o se recuperan con un aviso en español.
- Errores visibles en WSL y tmux: letra E/W en el margen, subrayado simple de
  color y mensaje al final de la línea del cursor. La barra de estado dice
  «Errores: 4  Avisos: 1» en lugar de `E:4 W:1`.
- `Espacio e` abre el explorador al instante; `Espacio E` localiza el archivo
  actual (sustituyen a `Espacio e e` y `Espacio e f`).
- Neovim avisa si falta ShellCheck al abrir Bash: sin él no hay diagnósticos.
- El instalador de alumno avisa si el repositorio está en `/mnt/c` en WSL2.
- `.gitattributes` fuerza finales de línea LF aunque Git use `core.autocrlf`,
  evitando `^M` en Neovim y archivos marcados como modificados en WSL2.

## 1.1.0 — 2026-09-27

- Ayuda de teclas con Espacio ? y F1, movimientos, edición, errores y snippets.
- Snippets propios para HTML, JavaScript, TypeScript y componentes/hooks React.
- JSDoc generado mediante TypeScript al escribir /** y Enter o Espacio lj.
- Completado nativo solicitado al escribir letras de nombres de variables.
- Líneas ajustadas al ancho, diagnósticos legibles en ventanas y hover delimitado.
- Guías de indentación de colores con plugin fijado; pliegues nativos.
- Instaladores con plan previo, Enter para iniciar, --yes para automatización,
  fases, colores, resumen de resultados y aviso explícito de fallo.
- README con rutas de instalación, diagrama Mermaid, opciones, actualización
  y activación opcional del comando nvim.

### Mejoras docentes incluidas desde la 1.0.0

- El instalador esencial admite `--perfil dwec` e instala únicamente Node,
  Neovim, plugins y servidores web, sin herramientas de PDF ni fixtures de
  prueba.
- Las terminales de las sesiones reciben el Node local verificado, por lo que
  `node`, `npm`, `npx` y Corepack funcionan sin modificar la shell del alumno.
- Los perfiles web exponen también el compilador `tsc` fijado por el entorno;
  los proyectos pueden seguir declarando su propia versión de TypeScript.
- Las instalaciones mínimas de Debian comprueban `xz-utils` y los certificados
  TLS antes de descargar Node, evitando un fallo que podía quedar oculto en
  sistemas WSL más completos.
- En Debian y Ubuntu, el modo `--sistema` comprueba `apt-get`, `sudo` y los
  certificados después de instalar, y explica cuándo debe intervenir el
  profesor o administrador.

Todos los cambios relevantes de este proyecto se documentan aquí.

### Evolución portable — 2026-09-13

- primera fase del entorno docente portable: perfiles inicial, DWEC, SI y
  profesor, con IA desactivada salvo opcion expresa;
- entrada sin tmux y sesiones optativas, con dos paneles sin IA y tres con IA;
- arranque nativo sin descargas ni bloqueo por servidores o plugins ausentes;
- herramientas privadas nuevas bajo `.tools/`, sin enlace global automatico;
- estado por perfil, runtime Wayland conservado y rutas personales recuperadas
  para lazygit y visores;
- correccion de `NVIM_BIN` en tmux para que conserve el wrapper aislado;
- pruebas de perfiles y navegacion nativa; regresion tmux adaptada a 3.7;
- Omarchy: pruebas locales de esta fase; WSL2/Debian y el entorno completo de
  lenguajes siguen pendientes de validacion en esta revision.

Los scripts de activacion/restauracion V1 se conservan, pero no son parte de
la via portable. No se actualizan dependencias ni se instalan herramientas
globales en esta fase.

## [1.0.0] - 2026-08-10

### Incluye

- configuración modular de Neovim 0.12.4 con dashboard nativo;
- búsqueda, exploración, edición, Git y Tree-sitter fijados;
- LSP y completado nativos para Lua, web y Python;
- sesiones tmux aisladas por proyecto y transporte seguro hacia agentes CLI;
- exportación Markdown a PDF A4 mediante Pandoc, CSS y Chromium;
- instalación, comprobación, activación y restauración reproducibles.

### Limitaciones conocidas

- solo Debian 13 x86_64 está probado;
- Arch/CachyOS y macOS siguen como objetivos sin validación real;
- BashLS está aplazado;
- Markdown/PDF presupone documentos propios y confiables;
- no se instala ni configura ningún proveedor de agentes.

El tag anotado `v1.0.0` queda pendiente de aprobación expresa y no forma parte
de esta preparación.
