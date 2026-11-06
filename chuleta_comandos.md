<img src="IMG/logo.png" alt="entorno-nvim · IFL" width="560">

# Chuleta de comandos: entorno IFL, tmux y Neovim

Guía básica para trabajar con los perfiles DWEC y Sistemas Informáticos. En los
atajos escritos como `Ctrl-a d`, pulse primero `Ctrl+a`, suelte las teclas y
después pulse `d`. En Neovim, `Espacio` es la tecla líder.

## 1. Instalar el entorno

### Primera instalación

```bash
git clone https://github.com/isaiasfl/entorno-nvim.git
cd entorno-nvim
./scripts/instalar-alumno.sh
```

Instala lo mismo para DWEC y SI: Git, tmux, búsqueda, Neovim, Node 24,
plugins y los servidores de HTML, CSS, JSON, JavaScript, TypeScript, React,
Tailwind, Bash (con ShellCheck), Python, Dockerfile y Docker Compose. Si faltan
programas del sistema, muestra el comando y pregunta antes de usar `sudo`.

No sustituye `~/.config/nvim` ni `~/.tmux.conf`. Tampoco instala o configura
cuentas de inteligencia artificial.

### Modos del instalador

| Orden | Resultado |
| --- | --- |
| `./scripts/instalar-alumno.sh` | Instala o completa el entorno |
| `./scripts/instalar-alumno.sh --comprobar` | Comprueba la instalación sin modificar nada |
| `./scripts/instalar-alumno.sh --help` | Muestra la ayuda |

Si la terminal todavía no reconoce `entorno-dev`, ejecute:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

### Actualizar una instalación existente

Guarde su trabajo y ejecute:

```bash
cd ~/entorno-nvim
./scripts/actualizar.sh
```

Descarga la versión nueva, ofrece cerrar las sesiones abiertas y reinstala con
su perfil. La primera vez, si su copia no tiene aún `actualizar.sh`:

```bash
cd ~/entorno-nvim
git restore . && git pull --ff-only && sh scripts/actualizar.sh
```

## 2. Abrir un proyecto

```bash
cd ~/ruta/del/proyecto
entorno-dev .
```

También puede indicar la ruta sin entrar antes:

```bash
entorno-dev ~/ruta/del/proyecto
```

### Opciones principales

| Opción | Uso |
| --- | --- |
| `--perfil alumno` | Todo para el alumnado (predeterminado tras instalar) |
| `--perfil inicial` | Perfil web sin diagnósticos |
| `--perfil profesor` | Perfil completo del profesor |
| `--ia` | Crea el panel de agente y habilita la integración |
| `--sin-ia` | Abre editor y terminal sin panel de IA |
| `--sin-tmux` | Abre solamente Neovim |
| `--elegir` | Muestra el selector de proyectos conocidos |

El entorno no instala clientes de IA ni credenciales. Si no existe Codex,
OpenCode, Claude o Pi, puede elegir `Shell` o trabajar sin IA.

## 3. Entender la pantalla tmux

La sesión inicial contiene:

- editor Neovim;
- terminal inferior;
- panel de IA a la derecha cuando se usa `--ia`.

El prefijo de tmux es `Ctrl+a`. Siempre se pulsa el prefijo, se suelta y luego
se pulsa la acción.

### Moverse y organizar paneles

| Acción | Teclas |
| --- | --- |
| Ir al editor | `Ctrl-a n` |
| Ir al agente | `Ctrl-a a` |
| Ir a la terminal | `Ctrl-a t` |
| Panel izquierdo/abajo/arriba/derecha | `Ctrl-a h/j/k/l` |
| Maximizar o restaurar el panel | `Ctrl-a z` |
| Dividir verticalmente | `Ctrl-a \|` |
| Dividir horizontalmente | `Ctrl-a -` |
| Redimensionar | `Ctrl-a H/J/K/L` |
| Mostrar números de panel | `Ctrl-a q` |
| Cerrar un panel | `Ctrl-a x`, confirmar |

### Ventanas de tmux, equivalentes aproximados a pestañas

| Acción | Teclas |
| --- | --- |
| Crear ventana | `Ctrl-a c` |
| Elegir ventana por número | `Ctrl-a 1` … `Ctrl-a 9` |
| Ventana anterior | `Ctrl-a p` |
| Mostrar selector de ventanas | `Ctrl-a w` |
| Renombrar ventana | `Ctrl-a ,` |
| Cerrar ventana completa | `Ctrl-a &`, confirmar |
| Abrir LazyGit | `Ctrl-a g` |

### Salir, volver y cerrar definitivamente

| Objetivo | Acción |
| --- | --- |
| Salir conservando editor y procesos | `Ctrl-a d` |
| Volver a la misma sesión | Repetir `entorno-dev RUTA` |
| Cerrar el proyecto definitivamente | `Ctrl-a Q`, confirmar |
| Listar sesiones desde la shell | `tmux -L entorno-nvim list-sessions` |
| Cerrar todas las sesiones del entorno | `tmux -L entorno-nvim kill-server` |

Cerrar SSH conserva la sesión tmux. Reiniciar la máquina no la conserva.
Guarde los archivos antes de cerrar definitivamente.

### Historial y copia de tmux

| Acción | Teclas |
| --- | --- |
| Entrar en modo copia | `Ctrl-a [` |
| Moverse | `h/j/k/l`, `Ctrl-u`, `Ctrl-d` |
| Comenzar selección | `v` |
| Copiar y salir | `y` |
| Salir sin copiar | `Esc` o `q` |
| Pegar el buffer de tmux | `Ctrl-a ]` |

La copia de tmux no siempre coincide con el portapapeles gráfico del equipo.

## 4. Neovim: ideas imprescindibles

Neovim es modal. Antes de ejecutar un atajo, pulse `Esc` para volver al modo
normal. Para escribir texto use `i`, `a`, `I`, `A`, `o` u `O`.

| Acción | Teclas |
| --- | --- |
| Insertar antes/después del cursor | `i` / `a` |
| Insertar al inicio útil/final de línea | `I` / `A` |
| Crear línea debajo/encima | `o` / `O` |
| Volver al modo normal | `Esc` o `jk` |
| Guardar | `Espacio w` o `:w` |
| Guardar y cerrar Neovim | `:wqa` |
| Cerrar sin guardar | `:qa!` |

### Moverse

| Acción | Teclas |
| --- | --- |
| Izquierda/abajo/arriba/derecha | `h/j/k/l` |
| Palabra siguiente/anterior/final | `w/b/e` |
| Inicio absoluto/primer texto/final de línea | `0/^/$` |
| Inicio/final del archivo | `gg/G` |
| Ir a la línea 25 | `25G` o `:25` |
| Media pantalla abajo/arriba | `Ctrl-d` / `Ctrl-u` |
| Centrar la línea actual | `zz` |

### Copiar, pegar, borrar y cambiar

| Acción | Teclas |
| --- | --- |
| Copiar línea | `yy` |
| Copiar tres líneas | `3yy` |
| Pegar debajo/encima | `p/P` |
| Borrar una línea | `dd` |
| Borrar tres líneas | `3dd` |
| Borrar carácter | `x` |
| Borrar palabra | `diw` |
| Cambiar palabra completa | `ciw`, escribir y `Esc` |
| Cambiar hasta final de línea | `c$`, escribir y `Esc` |
| Reemplazar un carácter | `r` y el nuevo carácter |
| Deshacer/rehacer | `u` / `Ctrl-r` |
| Repetir el último cambio | `.` |
| Duplicar línea | `Espacio d` |
| Mover línea abajo/arriba | `Alt-Shift-j/k` |

### Seleccionar texto

| Acción | Teclas |
| --- | --- |
| Selección por caracteres | `v` |
| Selección por líneas | `V` |
| Ampliar selección | `h/j/k/l` |
| Copiar/borrar selección | `y/d` |
| Cambiar selección | `c`, escribir y `Esc` |
| Reseleccionar lo último | `gv` |

Los borrados se guardan normalmente en registros de Vim, por lo que `p` puede
pegar lo borrado. El portapapeles gráfico depende de la terminal y del sistema.

## 5. Archivos, búsqueda y ventanas de Neovim

| Acción | Teclas |
| --- | --- |
| Mostrar/ocultar explorador | `Espacio e` |
| Buscar archivo | `Espacio f f` |
| Buscar texto en el proyecto | `Espacio f g` |
| Elegir buffer abierto | `Espacio f b` |
| Cambiar entre ventanas Neovim | `Ctrl-h/j/k/l` |
| Dividir horizontalmente | `:split` |
| Dividir verticalmente | `:vsplit` |
| Volver al inicio IFL | `:IFL` |
| Ayuda general de Vim | `:help` |

En el explorador, `Enter` abre, `a` crea, `r` renombra y `d` solicita
confirmación para borrar. Pulse `g?` dentro del explorador para ver su ayuda.

## 6. Diagnósticos y programación

| Acción | Teclas |
| --- | --- |
| Ver detalle del error bajo el cursor | `Espacio l d` |
| Error siguiente/anterior | `]d` / `[d` |
| Ir a definición/declaración | `gd` / `gD` |
| Ver documentación | `K` |
| Renombrar símbolo | `grn` |
| Ver referencias | `grr` |
| Solicitar completado | `Ctrl-Espacio` |
| Formatear con el LSP | `Espacio l f` |

En DWEC, los servidores de lenguaje muestran errores de JavaScript, TypeScript,
HTML, CSS y JSON. TypeScript aporta diagnósticos más precisos cuando el proyecto
tiene `tsconfig.json`. El editor no ejecuta el programa por sí solo: utiliza el
panel inferior de tmux para lanzar los comandos del proyecto.

Comprobaciones de un script Bash:

```bash
bash -n ejemplo.sh       # solo sintaxis; no ejecuta el script
shellcheck ejemplo.sh    # análisis estático
bash ejemplo.sh          # ejecuta: puede producir efectos y command not found
```

Desde Neovim puede abrir una terminal con `:terminal`; pulse `i` para escribir
y `Esc Esc` para regresar al modo normal. El panel inferior de tmux suele ser
más cómodo para ejecutar y observar el programa.

## 7. Ayuda y problemas frecuentes

| Situación | Solución |
| --- | --- |
| No aparece el texto de un error | `Espacio l d`; actualizar el repositorio y reiniciar la sesión |
| `entorno-dev: command not found` | `export PATH="$HOME/.local/bin:$PATH"` |
| La ayuda emergente parpadea | Actualizar con `./scripts/actualizar.sh`; el menú textual sustituye a fzf si este es incompatible |
| Neovim parece atrapado escribiendo | Pulse `Esc` |
| No sé en qué modo estoy | Pulse `Esc`; volverá con seguridad al modo normal |
| Quiero conservarlo todo al cerrar SSH | `Ctrl-a d` antes de salir, aunque cerrar SSH también conserva tmux |

Ayuda integrada:

- `Ctrl-a ?`: ayuda del entorno tmux;
- `:help asunto`: ayuda de Neovim, por ejemplo `:help dd`;
- `g?`: ayuda del explorador de archivos.

## 8. Leer Markdown bonito en la terminal

Una opción recomendable es **Glow**, un lector Markdown para terminal con modo
TUI y estilos claros/oscuros. No forma parte del instalador del alumnado: es
una herramienta opcional y debe instalarse solo después de revisar el paquete
disponible para el sistema.

Una vez instalado:

```bash
glow chuleta_comandos.md
glow -p chuleta_comandos.md   # usar paginador
```

Otra alternativa es **mdcat**, especialmente interesante en terminales como
kitty, WezTerm o iTerm2. Ninguno sustituye la previsualización HTML/PDF cuando
se necesita fidelidad gráfica, CSS, tablas complejas o imágenes.

## Leer documentación Markdown

En modo normal: **Espacio m r** lee el Markdown guardado con mdcat;
**Espacio m d** permite elegir documentación del proyecto. Dentro del visor,
**r** recarga y **q** cierra y vuelve al editor. Guarda antes con Espacio w.
La ventana tmux docs se reutiliza. Requiere mdcat disponible en PATH; no se
instala automáticamente. Detalles en [visor Markdown](docs/visor-markdown.md).
