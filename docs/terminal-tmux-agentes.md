# Terminal, tmux y agentes

## Arquitectura aislada

Cada proyecto usa una sesión tmux independiente con una ventana inicial `code`
y este layout:

```text
       Neovim (70%) | agente (30%)
----------------------------------
        terminal (15% de altura)
```

`entorno-dev` usa de forma predeterminada el wrapper aislado
`scripts/arrancar.sh`; no depende de `~/.config/nvim`. El panel de edición
arranca Neovim sin argumentos y situado en la carpeta solicitada, por lo que
muestra el dashboard IFL. Desde el dashboard, `e` abre el árbol de archivos;
en cualquier buffer, `<leader>e` lo abre o cierra.

El flujo usa por defecto el servidor dedicado `entorno-nvim`, mediante
`tmux -L entorno-nvim`. Así no carga opciones, atajos ni sesiones en el servidor
tmux personal del usuario. Puede elegirse otro nombre antes de arrancar:

```sh
export ENTORNO_TMUX_SOCKET=otro-entorno
entorno-dev /ruta/al/proyecto
```

Para inspeccionar o recuperar el servidor predeterminado se usan, por ejemplo,
`tmux -L entorno-nvim list-sessions` y `tmux -L entorno-nvim attach`.
`proyecto.sh` solo crea el layout cuando la sesión no existe: al reconectar
conserva paneles, procesos, tamaños y ventanas.
Una ruta explícita (`entorno-dev .` o `entorno-dev /ruta/ejercicio`) se respeta
incluso si es una subcarpeta de un repositorio Git: cada carpeta tiene su
sesión. `--elegir` sigue seleccionando raíces de repositorios. Al reconectar
con una sesión existente se recupera su estado; no se cambia a la fuerza el
directorio de un editor o una terminal que ya estaban abiertos.
Al crear una sesión desconectada usa las dimensiones del terminal que la lanza;
desde el selector emergente toma las del cliente tmux de origen. Así los
porcentajes iniciales no se deforman al conectar una terminal grande.

La configuración versionada está en `tmux/tmux.conf`. La suite tmux se validó
con tmux 3.5a en Debian 13 y 3.6b en macOS Apple Silicon. No usa TPM, plugins,
`tmux-resurrect` ni `vim-tmux-navigator`. CachyOS sigue pendiente de una
ejecución real y la validación completa de Neovim en macOS es independiente.

## Barra de estado

La barra ASCII muestra la sesión y las ventanas mediante formatos nativos de
tmux. A la derecha, `scripts/tmux-status.sh` consulta cada 15 segundos la rama
Git y el agente del panel marcado con `@entorno_role=agent`; la hora la formatea
tmux sin lanzar otro proceso. Un asterisco tras la rama indica cambios staged o
en archivos versionados. Para evitar recorridos costosos, los archivos nuevos
sin seguimiento no se incluyen en este indicador.

```text
entorno-nvim | [1:code] | git:main * | AI:Codex | 10:35
```

La raíz canónica se conserva en la opción de sesión
`@entorno_project_root`, por lo que Git no depende del directorio del panel
activo. Si no hay agente muestra `AI:-`; los valores conocidos son Codex,
OpenCode, Pi y Shell. La salida usa ASCII y funciona sin Nerd Font, TPM ni
plugins tmux. La paleta se limita a los 16 colores ANSI: el proyecto aparece en
cian, las ventanas inactivas en gris y la ventana activa usa fondo cian, texto
negro y negrita. Los corchetes ASCII mantienen visible la ventana activa aunque
el cliente no reproduzca los colores. Los índices permiten saltar directamente
a futuras ventanas como `2:git`, `3:server` o `4:logs`, sin crearlas
automáticamente. Los separadores usan un gris discreto y la hora recupera el
cian del proyecto para cerrar visualmente la barra.

tmux es la única dependencia específica de esta fase. Estos comandos son solo
referencias para una instalación aprobada expresamente en cada sistema; esta
revisión no instaló paquetes:

```sh
# Debian
sudo apt install tmux

# CachyOS / Arch
sudo pacman -S tmux

# macOS con Homebrew
brew install tmux
```

En macOS también debe comprobarse que el emulador de terminal conoce el tipo
`tmux-256color`. El selector emergente descrito abajo requiere que la versión
de tmux incluya `display-popup`; se ha validado con tmux 3.5a en Debian. No se
ha probado todavía en CachyOS ni macOS.

## Selección de proyectos

Las raíces pueden configurarse explícitamente mediante una lista separada por
dos puntos; nunca se recorre todo el directorio personal:

```sh
export ENTORNO_TMUX_PROJECT_ROOTS="$HOME/Proyectos:$HOME/Projects"
./scripts/proyecto.sh
```

Si la variable no existe, el fallback se limita a `$HOME/Proyectos` y
`$HOME/Projects` que existan. Si ninguno existe, el selector muestra un error
claro y pide definir `ENTORNO_TMUX_PROJECT_ROOTS`.

El selector reconoce `fd` y `fdfind`, repositorios normales y worktrees. Si se
cancela fzf, termina sin crear una sesión parcial. También puede abrirse una
ruta concreta:

```sh
./scripts/proyecto.sh /ruta/al/proyecto
```

Dentro de cualquier panel de una sesión gestionada por este entorno,
`Ctrl-a P` abre el mismo selector en un popup centrado del 85% por 75%. El
popup usa un borde ASCII sencillo y parte del directorio del panel actual. El
lanzador `scripts/popup-proyecto.sh` solo conserva el cliente, panel y sesión de
origen; delega en `scripts/proyecto.sh`, por lo que no existe un segundo
sessionizer ni otra implementación del descubrimiento. `Esc` y `Ctrl-C`
cancelan fzf, cierran el popup y no crean sesiones parciales.

Las shells de paneles creados antes de guardar el entorno de sesión no reciben
retroactivamente esas variables, y el proceso del popup tampoco conserva
necesariamente `TMUX_PANE`. Por ello, el binding resuelve primero el
identificador de su sesión y lo pasa explícitamente al popup. Tanto el popup
como `proyecto.sh` usan ese destino con `tmux show-environment -t` para recuperar
la raíz, el socket, los roots, la profundidad y `NVIM_BIN` que falten. No se usa
el entorno global del servidor —que podría mezclar sesiones— y `Ctrl-a P` no
depende de que la raíz esté exportada en la shell del panel.

Si se define `ENTORNO_TMUX_PROJECT_ROOTS`, debe exportarse al iniciar o
reconectar el proyecto. `proyecto.sh` conserva en la sesión los roots efectivos,
incluidos los del fallback, la profundidad y el
ejecutable de Neovim que recibió, para que el popup pueda crear otra sesión con
las mismas reglas. La selección conecta con una sesión existente sin tocar su
layout o crea el layout normal cuando todavía no existe. Todo ocurre en el
socket indicado por `ENTORNO_TMUX_SOCKET`, que sigue siendo `entorno-nvim` por
defecto.

El nombre de sesión combina el nombre limpio del directorio con una suma de su
ruta canónica. Esto evita colisiones sin dejar un guion bajo espurio al final.
Por defecto se usa el wrapper aislado de este repositorio. `NVIM_BIN` permite
anularlo explícitamente para pruebas o para escoger otro editor compatible:

```sh
NVIM_BIN=/ruta/a/otro/nvim entorno-dev /ruta/al/proyecto
```

Al salir de Neovim, el panel de trabajo vuelve a su shell en vez de desaparecer.
Puede abrirse de nuevo con el wrapper para recuperar la configuración aislada.
Volver a ejecutar `proyecto.sh` conecta con la sesión existente sin reconstruir
el layout.

## Teclas y tmux anidado

El prefijo es `Ctrl-a`. Como esa tecla significa «principio de línea» en shells
con edición Emacs y tiene acciones propias en algunas aplicaciones, `Ctrl-a
Ctrl-a` envía un `Ctrl-a` literal al panel. El ratón está activo como segunda
vía para seleccionar paneles y ventanas, redimensionar y recorrer el historial;
los bindings de teclado siguen siendo el flujo principal.

Los tres paneles iniciales se identifican por su responsabilidad mediante
`@entorno_role`, no por su número ni por su posición física. Por ello, la
navegación sigue funcionando aunque el layout cambie:

| Tecla | Acción |
| --- | --- |
| `Ctrl-a n` | Ir al panel Neovim/editor |
| `Ctrl-a a` | Ir al panel del agente IA |
| `Ctrl-a i` | Abrir el selector IA en un popup |
| `Ctrl-a t` | Ir al panel terminal |
| `Ctrl-a h/j/k/l` | Cambiar de panel |
| `Ctrl-a H/J/K/L` | Redimensionar panel |
| `Ctrl-a \|` / `Ctrl-a -` | Dividir a derecha / debajo |
| `Ctrl-a c` | Crear una ventana |
| `Ctrl-a g` | Abrir o recuperar lazygit en una ventana dedicada |
| `Ctrl-a ?` | Abrir la ayuda contextual del entorno |
| `Ctrl-a p` | Ventana anterior |
| `Ctrl-a P` | Seleccionar o crear una sesión de proyecto en un popup |
| `Ctrl-a z` | Maximizar o restaurar el panel |
| `Ctrl-a [` | Entrar en modo copia Vi |
| `Ctrl-a s` | Elegir una sesión |
| `Ctrl-a d` | Separarse sin detenerla |
| `Ctrl-a Ctrl-a` | Enviar `Ctrl-a` literal o el prefijo a un tmux remoto |

Dentro de Neovim, `Ctrl-h/j/k/l` sigue navegando entre splits. Para cruzar a
tmux se pulsa primero `Ctrl-a`.

`Ctrl-a g` busca en la sesión una ventana marcada con
`@entorno_window_role=git`. Si existe la selecciona, aunque haya sido
renombrada; si no existe, crea una ventana en `@entorno_project_root` y ejecuta
`lazygit` directamente. Si el ejecutable no está instalado muestra un error en
tmux y no crea ninguna ventana. La ventana desaparece normalmente al salir de
lazygit y se vuelve a crear la próxima vez que se use el atajo.

`Ctrl-a ?` abre una ayuda interactiva por capas dentro de un popup con borde
redondeado de caracteres Unicode estándar, sin depender de Nerd Fonts. El
primer nivel presenta flujo diario, editor, inteligencia artificial, tmux y
espacio de trabajo, Git, terminal, navegación y configuración. Flujo diario
permanece primero y el contexto actual ocupa la segunda posición. La cabecera
explica `PREFIX = CTRL-a` y `SPACE = leader Neovim`; las acciones usan después
esas etiquetas en vez de repetir combinaciones técnicas. Enter muestra una
categoría y Esc vuelve al primer nivel. `q`, o Esc desde la raíz, cierra sin
ejecutar acciones. La interfaz principal usa fzf y conserva un menú POSIX cuando
falta.

La ventana `git` se reconoce mediante `@entorno_window_role=git`; editor, agente
y terminal se reconocen mediante `@entorno_role`. Editor incluye movimientos y
modos básicos de Vim, duplicación y desplazamiento de líneas o selecciones.
Configuración documenta `Espacio u t`, el selector de
Catppuccin, Tokyo Night y Kanagawa. Inteligencia artificial muestra la
disponibilidad real de Codex, OpenCode, Claude, Pi y Shell y explica el recorrido
seguro de contexto desde Neovim.

Ejecutar `proyecto.sh` desde el mismo servidor dedicado cambia de cliente sin
anidar tmux. Si se detecta que la terminal ya pertenece a otro socket, el script
se detiene con un mensaje claro: hay que separarse y lanzarlo desde una terminal
externa. En una sesión SSH con tmux remoto, `Ctrl-a Ctrl-a` envía el prefijo al
servidor remoto. Esta política mínima evita anidamientos locales ambiguos; el
flujo SSH real aún no se ha probado en este equipo.

## Selector del panel de agente

El panel derecho conserva `@entorno_role=agent` y arranca un selector propio al
crear una sesión nueva. Si fzf está disponible usa una interfaz filtrable; si
falta, ofrece un menú textual numerado. No depende de TPM ni de plugins tmux y
no instala, autentica ni configura clientes.

Las opciones estables son Codex, OpenCode, Claude, Pi, Shell y Salir. Tanto fzf
como el menú textual muestran siempre el catálogo completo y conservan su
orden. El nombre aparece primero y las marcas ASCII `[OK]` y `[--]` alineadas a
su derecha indican si el ejecutable está disponible. fzf recuerda las acciones
Enter y Esc; el fallback POSIX muestra Enter y `0` para cerrar, sin depender de
símbolos Unicode.

En el popup, el catálogo se limita a Codex, OpenCode, Claude, Pi y Shell: no
incluye números ni una fila Salir porque Esc ya cancela fzf. El fallback pide
escribir el nombre y acepta una entrada vacía para cerrar. El selector embebido
conserva su opción Salir y su comportamiento anterior.

Elegir uno ausente muestra un aviso claro y vuelve al menú sin cerrar el panel
ni publicar metadata de agente. Para forzar el fallback, por ejemplo en una
sesión SSH limitada:

```sh
export ENTORNO_AGENT_SELECTOR_USE_FZF=0
```

Cada agente se arranca obligatoriamente mediante `scripts/agente.sh`. Mientras
la selección está activa, el panel publica una segunda opción para futuras
integraciones visuales:

```text
@entorno_agent=codex
@entorno_agent=opencode
@entorno_agent=claude
@entorno_agent=pi
@entorno_agent=shell
```

Al abandonar normalmente el agente o ejecutar `exit` en la shell elegida se
vuelve al selector y se limpia `@entorno_agent`, sin alterar
`@entorno_role=agent`. Cancelar el selector devuelve el panel a su shell base.
La detección normal distingue ejecutables nativos de wrappers con shebang Node.
Si un empaquetado particular expone otro proceso, puede declararse sin ampliar
la allowlist mediante `ENTORNO_AGENT_CODEX_PROCESS`,
`ENTORNO_AGENT_OPENCODE_PROCESS`, `ENTORNO_AGENT_CLAUDE_PROCESS` o
`ENTORNO_AGENT_PI_PROCESS`.

Justo antes de ejecutar Codex, OpenCode, Claude o Pi, `scripts/agente.sh`
elimina el scrollback del panel con tmux y limpia la pantalla mediante una
secuencia ANSI.
La operación sucede después de validar el rol, el ejecutable y la metadata, por
lo que los errores siguen siendo visibles y `<leader>ac` conserva su contrato.
No se aplica a la opción Shell ni cambia el ciclo selector → shell → agente.

El selector embebido sigue arrancando dentro del panel para que las sesiones
puedan crearse sin un cliente tmux conectado. Cuando está esperando una
elección, `Ctrl-a i` ofrece una segunda interfaz en un popup centrado con el
mismo borde redondeado que la ayuda contextual.
La elección se entrega al selector original, que conserva en exclusiva el
lanzamiento, la metadata y el retorno automático. Si hay un agente o una shell
activos, el atajo muestra un aviso y `Ctrl-a a` vuelve a ese panel sin enviarle
teclas accidentalmente ni generar un error de `run-shell`. Mientras el popup
está abierto, el contenido del panel agente se oculta con un estilo tmux
temporal y se restaura siempre al cerrarlo.
El borde permanece continuo y el título aparece una sola vez dentro.
Cerrar con Esc, perder el cliente o repetir el atajo mientras el popup anterior
termina se consideran cierres normales y no generan errores de `run-shell`.

## Destino seguro para el contexto

El panel derecho se marca con `@entorno_role=agent` y comienza en el selector.
Mientras no haya un agente activo, cancelar a la shell tampoco convierte el
panel en un destino válido. Antes de pegar, el transporte consulta su
`pane_current_command` y exige exactamente un panel con ese rol.

Las shells `bash`, `sh`, `dash`, `zsh`, `fish`, `ksh`, `tcsh` y `nu` se deniegan
siempre. Un proceso desconocido también se deniega por defecto y el error indica
el valor detectado y cómo autorizar un agente nuevo. Los agentes conocidos por
defecto son `codex`, `opencode`, `claude`, `pi` y `jarvis-coder`, sin que esta
lista cierre la arquitectura a otros proveedores.

En este Debian se midieron estos valores reales:

| Cliente disponible | `pane_current_command` observado |
| --- | --- |
| Codex | `node` de forma persistente |
| OpenCode | `node` al arrancar; después `opencode` |
| Claude Code | `env` al arrancar; después `claude` |
| Bash / sh / dash | `bash` / `sh` / `dash` |
| pi / jarvis-coder | No estaban instalados; no se midieron |

Por tanto, `node` no se permite globalmente: también podría ser una aplicación
arbitraria. Para agentes envueltos por Node u otro proceso se usa el lanzador
agnóstico, que asocia temporalmente una identidad permitida con el proceso real:

```sh
$ENTORNO_NVIM_ROOT/scripts/agente.sh --name codex --process node codex
```

Al terminar el cliente, el lanzador retira esa asociación. La identidad solo es
válida mientras el proceso observado siga coincidiendo, por lo que volver a una
shell no deja una autorización obsoleta.

Para añadir un agente nuevo sin cambiar código, se amplía la lista y se inicia
directamente o mediante el lanzador. La variable admite espacios, comas o dos
puntos:

```sh
export ENTORNO_AGENT_ALLOWED_COMMANDS="mi-agente otro-agente"
$ENTORNO_NVIM_ROOT/scripts/agente.sh \
  --name mi-agente --process node mi-agente
```

La variable debe estar en el entorno de Neovim y del panel de agente. Ni este
flujo ni el lanzador instalan, configuran o leen credenciales de proveedores.

## Envío desde Neovim

`<leader>ac` (`Espacio a c`) envía metadatos de proyecto, archivo y posición,
además del prompt solicitado. En modo visual añade rango, tipo y texto exacto;
se soportan selecciones por caracteres, líneas y bloque. El modo normal no lee
el archivo completo.

El payload se codifica como JSON en una sola línea, se escribe con modo `0600`
en el directorio runtime `agent-context` de modo `0700`, se carga en un buffer
interno de tmux y se pega mediante bracketed paste. No usa el portapapeles y
nunca envía Enter: el usuario debe revisar el texto y enviarlo manualmente.

El límite predeterminado es 32768 bytes. Lua calcula un único valor efectivo y
lo entrega al transporte, de modo que ambas capas respetan el mismo override:

```sh
export ENTORNO_AGENT_CONTEXT_MAX_BYTES=65536
```

Tras un envío correcto se eliminan el temporal y el buffer tmux. Ante un error,
el temporal se conserva y el mensaje muestra su ruta. En cada intento se purgan
solo archivos regulares propios con forma `context-<pid>-<nonce>.json` de más de
24 horas dentro del directorio runtime. No se siguen enlaces simbólicos ni se
borran nombres ajenos.

Se bloquean preventivamente `.env*`, `.git-credentials`, `.netrc`, `.npmrc`,
`.pypirc`, `.pgpass`, `.my.cnf`, `.s3cfg`, claves `*.pem`, `*.key`, `*.p12`,
`.kube/config`, `.docker/config.json` y rutas bajo `.ssh`, `.gnupg` o
`.password-store`, además de algunos nombres habituales de credenciales. Es una
barrera para errores comunes, no un sistema DLP: el usuario debe revisar siempre
el contexto y no seleccionar secretos.

## Flujo y recuperación

1. Ejecutar `scripts/proyecto.sh` y escoger el repositorio.
2. Elegir Codex, OpenCode o Pi en el selector del panel derecho.
3. Trabajar en Neovim y usar `<leader>ac` en modo normal o visual.
4. Revisar el contexto pegado en el agente y pulsar Enter manualmente.
5. Usar el panel inferior para pruebas y servidores.
6. Separarse con `Ctrl-a d`; `proyecto.sh` recupera después la misma sesión.

Un reinicio elimina los procesos de tmux; el script recrea el layout, pero no
las conversaciones. Su reanudación corresponde a cada cliente. OpenCode,
JARVIS y otros proveedores no se configuran en esta fase.
