![entorno-nvim — entorno de programación de Isaías](IMG/logo.png)


*Neovim de Isaías: desarrollo, docencia y Markdown/PDF.*

**[Guía completa de teclas y uso](docs/guia-completa-teclas.md)**: editor,
explorador, pestañas, tmux, consola, IA, PDF, autocompletado y LazyGit.

**[Chuleta para alumnado](chuleta_comandos.md)**: instalación,
sesiones tmux, edición básica en Neovim, diagnósticos y ejecución de Bash.

**[Fragmento HTML para Moodle DWEC](docs/moodle-dwec.html)**: entrada breve con
instalación, enlaces, bloques de comandos, atajos e incidencias.

## Alumnado: empiece aquí

Elija **su caso** y copie los comandos en una terminal de Linux (en Windows,
en la terminal de **WSL2/Ubuntu**, dentro de su carpeta personal `~`, nunca en
`/mnt/c`).

**El mismo `scripts/instalar-alumno.sh` sirve para Intel/AMD (x86_64) y
ARM64 (por ejemplo, Snapdragon con Windows y WSL2).** Detecta la arquitectura
y descarga Neovim y Node nativos, con versiones y SHA-256 fijados. No hay que
elegir otro script ni pasar una opción ARM. Los paquetes del sistema se
obtienen del gestor de Linux, que selecciona la arquitectura correspondiente.

En Windows, primero debe tener **WSL2 con Ubuntu o Debian**; estos comandos
se ejecutan en su terminal de Linux, no en PowerShell. ARM de 32 bits y Windows
sin WSL no están admitidos por este instalador. El instalador general del
profesor (`instalar.sh`, con PDF/LuaLS/Tree-sitter) conserva sus propios límites.

**Validación:** instalación y repetición reales del carril de alumnado en
Linux x86_64; detección simulada y artefactos oficiales verificados para
ARM64. La instalación completa en un portátil WSL2 ARM64 sigue pendiente;
no se presenta como probada en ese hardware.

### Caso 1: primera vez (nunca lo ha instalado)

```sh
cd ~
git clone https://github.com/isaiasfl/entorno-nvim.git
cd entorno-nvim
./scripts/instalar-alumno.sh
```

Instala el entorno completo del alumnado, igual para DWEC y SI: HTML, CSS,
JavaScript, TypeScript, React, Tailwind, Bash, Python, Dockerfile y Docker
Compose. Si faltan programas del sistema, los muestra y pregunta antes de
instalarlos (pedirá su contraseña). Al terminar ofrece añadir `entorno-dev`
al PATH: responda `s`.

### Si falló la instalación anterior en ARM64

Si ya descargó el repositorio y el instalador anterior rechazó ARM, no hace
falta borrar su carpeta. Desde WSL2, guarde su trabajo y ejecute:

```sh
cd ~/entorno-nvim
./scripts/actualizar.sh
```

El actualizador descarga los cambios y ejecuta el instalador compatible.
Funciona aunque la instalación anterior no llegara a guardar el perfil:
en ese caso pide Enter para comenzar. Si no existe `scripts/actualizar.sh`,
use el caso 3 de abajo.

Si Git avisa de cambios locales, consérvelos o consulte al profesor antes de
descartarlos. Si falla de nuevo, copie el mensaje completo y la salida de
`uname -m` y `cat /etc/os-release` (sin datos personales ni credenciales).

### Caso 2: ya lo tenía instalado y tiene `scripts/actualizar.sh`

Guarde su trabajo y ejecute:

```sh
cd ~/entorno-nvim
./scripts/actualizar.sh
```

Descarga la versión nueva, ofrece cerrar las sesiones abiertas y reinstala
todo lo nuevo. Pulse Enter si pregunta. **No hace falta reinstalar a mano:**
aunque instalara antes solo DWEC o solo SI, la actualización completa lo que
falte (web, Bash, Python y Docker).

### Caso 3: ya lo tenía instalado, pero su copia no tiene `actualizar.sh`

Solo la primera vez:

```sh
cd ~/entorno-nvim
git pull --ff-only
sh scripts/actualizar.sh
```

Si Git avisa de cambios locales (por ejemplo, finales de línea `^M` o
`lazy-lock.json`), consulte al profesor antes de descartarlos. Desde entonces,
use el caso 2.

### Caso 4: empezar de cero (si algo sigue fallando)

Guarde su trabajo y descargue una copia limpia; la antigua se conserva por
si acaso:

```sh
tmux -L entorno-nvim kill-server
cd ~
mv entorno-nvim entorno-nvim.antiguo
git clone https://github.com/isaiasfl/entorno-nvim.git
cd entorno-nvim
./scripts/instalar-alumno.sh
```

El comando `entorno-dev` se redirige solo a la copia nueva. Cuando compruebe
que todo funciona, puede borrar la antigua: `rm -rf ~/entorno-nvim.antiguo`.

### Trabajar cada día

```sh
cd ~/ruta/de/mi-proyecto
entorno-dev .
```

Abre Neovim arriba y una terminal abajo. Dentro de Neovim, pulse `Espacio`
y espere: aparece el menú con todas las acciones. Si la terminal dice que no encuentra
`entorno-dev`, abra una terminal nueva o use `~/entorno-nvim/bin/entorno-dev .`

### Si algo falla

```sh
cd ~/entorno-nvim
./scripts/instalar-alumno.sh --comprobar
```

Copie el mensaje completo y envíelo al profesor. Problemas habituales en
[la guía del alumno](docs/alumno.md#5-solución-de-problemas).

## Qué es

La evolucion docente portable ya dispone de perfiles y arranque minimo sin
dependencias opcionales. Consulte [estado y uso actual](docs/entorno-docente.md).
La V1 descrita mas abajo es la referencia historica completa en Debian;
esta fase se prueba en Omarchy y aun no certifica WSL2.

`entorno-nvim` v1.1.0 es una configuración de Neovim y tmux comprensible,
versionada y reversible para programación, docencia y documentos Markdown.
La referencia probada es Debian 13 con Neovim 0.12.4.

## Qué incluye

- Neovim modular en Lua, dashboard IFL, búsqueda, explorador y Git.
- LSP nativo para Lua, web y Python; completado nativo de Neovim 0.12.
- Tree-sitter con ocho parsers externos fijados.
- sesiones tmux por proyecto en el socket dedicado `entorno-nvim`;
- Markdown → HTML/CSS → Chromium → PDF A4 (Pandoc opcional, sólo para PDF).
- Ortografía en español e inglés en Markdown y texto: faltas en rojo, menú `Espacio o`.
- `scripts/actualizar.sh` para actualizar con un solo comando.

El [inventario V1](docs/inventario-v1.md) detalla componentes y versiones.

## Empiece aquí: elegir la instalación

Descargue el repositorio y consulte la ayuda si tiene dudas:

```sh
git clone https://github.com/isaiasfl/entorno-nvim.git
cd entorno-nvim
./scripts/instalar.sh --help
```

**Para el alumnado (DWEC y SI), use el instalador de alumno. Para el entorno completo
con Markdown/PDF, use el instalador general.** Son alternativas; no necesita
ejecutar los dos.

```mermaid
flowchart TD
    A[Descargar entorno-nvim] --> B{¿Qué necesita?}
    B -->|Alumnado DWEC y SI| C[instalar-alumno.sh]
    B -->|Entorno completo y PDF| E[instalar.sh --sistema]
    C --> F[entorno-dev .]
    E --> H[Abrir proyecto con perfil profesor]
```

### Comandos para instalar y abrir

Ejecute desde la carpeta del repositorio la pareja que corresponda:

| Uso | Instalar | Abrir su proyecto |
| --- | --- | --- |
| Alumnado DWEC y SI: web, Bash, Python y Docker | `./scripts/instalar-alumno.sh` | `./bin/entorno-dev /ruta/a/mi-proyecto` |
| Profesor: entorno completo y Markdown/PDF | `./scripts/instalar.sh --sistema` | `./bin/entorno-dev --perfil profesor --sin-ia /ruta/a/mi-proyecto` |

Sustituya `/ruta/a/mi-proyecto` por la carpeta de su proyecto. Para abrir la
carpeta actual, use `.`. `--sin-ia` permite empezar con editor y terminal;
la IA es opcional y requiere un cliente ya instalado y configurado.

Antes de instalar se muestra el plan y se pide **Enter para comenzar**;
Ctrl+C cancela. La ayuda y la comprobación no inician una instalación.

### Qué significan las opciones

| Opción | Dónde se usa | Efecto |
| --- | --- | --- |
| `--yes` o `-y` | Ambos instaladores | Omite solo la pausa inicial para automatización; no autoriza sudo |
| `--help` o `-h` | Ambos instaladores | Muestra ayuda y termina sin instalar |
| `--perfil dwec` / `--perfil si` | Instalador de alumno | Se aceptan por compatibilidad; instalan lo mismo que sin opción |
| `--sistema` | Instalador general | Ofrece instalar los paquetes del sistema que falten; muestra el comando y pide confirmación antes de usar sudo |
| `--sin-sistema` | Instalador de alumno | Nunca usa sudo; solo indica qué paquetes faltan. Sin esta opción pregunta antes de instalarlos |
| `--comprobar` | Instalador de alumno | Comprueba la instalación sin descargar ni modificar |

El instalador de alumno pregunta antes de instalar paquetes del sistema que
falten; acepta `--sistema` por compatibilidad. Sin `--sistema`, el instalador
general prepara sus componentes locales y muestra cómo resolver los paquetes
del sistema que falten. El instalador general no
acepta `--perfil` ni `--comprobar`. Para comprobar requisitos generales:

```sh
./scripts/comprobar-requisitos.sh
```

### Qué cambia en su equipo

Ambas instalaciones mantienen Neovim separado: **no sustituyen
`~/.config/nvim` ni `~/.tmux.conf`**. Neovim, Node, plugins y servidores de
lenguaje se preparan dentro del repositorio. El instalador de alumno también
prepara el lanzador `entorno-dev` en `~/.local/bin`; puede usar siempre
`./bin/entorno-dev` sin depender de su PATH.

El alumnado no necesita las herramientas PDF. La instalación completa las
incluye en su flujo. Los paquetes del sistema se obtienen del gestor de la
plataforma: **Lazygit usa la versión disponible en el sistema, no descarga
necesariamente la última publicación de GitHub ni actualiza una ya instalada**.
Las versiones de los componentes locales se controlan mediante las referencias
y lockfiles del proyecto.

Para detalles y resolución de incidencias, consulte [la guía de alumnado](docs/alumno.md)
y [la instalación completa](docs/instalacion.md).

### Actualizar una instalación existente

Guarde su trabajo, entre en la carpeta de `entorno-nvim` y ejecute:

```sh
./scripts/actualizar.sh
```

Corrige archivos alterados por finales de línea de Windows, restaura
`nvim/lazy-lock.json` si cambió sin querer, ofrece cerrar las sesiones tmux
antiguas, hace `git pull --ff-only` y repite la instalación. Para el entorno completo del profesor: `./scripts/actualizar.sh --completo`.

**Primera vez en copias anteriores a `actualizar.sh`** (desde la carpeta del
repositorio; conserve cualquier cambio local si Git impide avanzar):

```sh
git pull --ff-only
sh scripts/actualizar.sh
```

`--ff-only` solo avanza la copia hasta la versión publicada: si hubiera
cambios o commits locales que exigieran mezclar, se detiene sin tocar nada en
lugar de crear un commit de mezcla o un conflicto.

## Comprobar requisitos

```sh
./scripts/comprobar-requisitos.sh
```

Solo lee el estado y clasifica cada elemento como `OK`, `FALTA` u `OPCIONAL`.

## Usar entorno-dev desde cualquier carpeta

La instalación **no sustituye el comando `nvim` existente**. Puede empezar sin
cambiar el PATH ni la configuración habitual:

```sh
./bin/entorno-dev /ruta/a/mi-proyecto
./scripts/arrancar.sh /ruta/a/archivo
```

Ambos instaladores preparan el lanzador en `~/.local/bin`. Para una instalación
anterior o para repararlo, ejecute una sola vez desde el repositorio:

```sh
./scripts/instalar-entorno-dev.sh
```

`~/.local/bin` debe estar en su PATH. El instalador avisa si falta. En Bash/Zsh,
para la terminal actual: `export PATH="$HOME/.local/bin:$PATH"`. En Fish:
`fish_add_path "$HOME/.local/bin"`. Compruebe con `command -v entorno-dev`.

Para conservarlo en Bash/Zsh, añada `export PATH="$HOME/.local/bin:$PATH"` a
`~/.bashrc` o `~/.zshrc`, respectivamente, y abra otra terminal. Fish conserva
la ruta con `fish_add_path`. El instalador ofrece al terminar configurar el PATH permanentemente, con
confirmación separada y copia previa. `--yes` no acepta esa modificación.
Si responde que no, puede usar estas instrucciones manuales.

Después, desde la carpeta del proyecto:

```sh
entorno-dev .
```

Escribir solo `entorno-dev` usa el perfil del alumnado si se instaló con
`instalar-alumno.sh`; si no, el perfil profesor.

### Usar este entorno al escribir nvim

**`activar.sh` cambia tanto el comando como la configuración habitual de
Neovim**, no solo el PATH. Crea una copia fechada y enlaza `~/.config/nvim`
y `~/.local/bin/nvim`. Es opcional; si quiere conservar Omarchy u otra
configuración, utilice los lanzadores anteriores.

Para la instalación local de Linux descrita aquí, desde el repositorio:

```sh
# Bash/Zsh: ~/.local/bin debe ir antes de las rutas del sistema.
export PATH="$HOME/.local/bin:$PATH"
ENTORNO_NVIM_TARGET="$PWD/.tools/nvim-0.12.4/bin/nvim" ./scripts/activar.sh
command -v nvim
nvim --version
```

La variable indica el binario instalado en el repositorio: el valor
predeterminado de `activar.sh` corresponde a la ubicación histórica en
`~/.local/opt`. Si usa otra ubicación o plataforma, indique la ruta real de su
binario compatible. En Fish use `fish_add_path --prepend "$HOME/.local/bin"`
y `env ENTORNO_NVIM_TARGET="$PWD/.tools/nvim-0.12.4/bin/nvim" ./scripts/activar.sh`.

El script no edita la configuración de su shell. Para conservar el PATH en
Bash/Zsh, añada la línea apropiada al archivo de inicio de su shell.
Detalles y copias en [activación](docs/activacion.md); para deshacer la
activación, consulte [restauración](docs/restauracion.md).

## Restaurar

```sh
./scripts/restaurar.sh
```

Restaura la configuración y el comando de Neovim anteriores desde el último
backup registrado. El backup histórico se conserva. Véase
[restauración](docs/restauracion.md).

## Flujo diario

```sh
cd /ruta/al/proyecto
entorno-dev
```

Sin opciones usa el perfil instalado: alumnado (editor y terminal) o
profesor (PDF y tmux con tres paneles).
`--sin-tmux` abre solo Neovim; `--sin-ia` omite el agente.
La [guia docente](docs/entorno-docente.md)
describe los perfiles y la [chuleta diaria](docs/chuleta.md) los atajos.
El lanzador acepta otra ruta con `entorno-dev /ruta` y abre el selector con
`entorno-dev --elegir`. Use `entorno-dev` desde cualquier carpeta. Si no se encuentra el comando,
consulte la sección de PATH anterior. `./bin/entorno-dev` es una alternativa
desde el repositorio.

## Neovim

`./scripts/arrancar.sh` ejecuta Neovim con datos, cache y estado aislados.
Conserva el runtime del escritorio y separa sus propios sockets y contextos.
No cambia la configuracion activa. [Arquitectura docente](docs/entorno-docente.md).

## tmux

El flujo usa `tmux -L entorno-nvim` y no carga ni altera `~/.tmux.conf`.
`Ctrl-a P` abre el selector de proyectos en un popup; el ratón queda disponible
como apoyo y la navegación principal sigue siendo por teclado. `Ctrl-a ?` abre
una ayuda interactiva por categorías para el flujo diario, editor, IA, espacio
de trabajo tmux, Git, terminal, navegación y configuración. Más detalles en
[terminal y tmux](docs/terminal-tmux-agentes.md).

## Agentes

El panel derecho admite agentes CLI intercambiables. `<leader>ac` pega contexto
solo tras validar el proceso de destino y nunca envía Enter. El entorno no
instala agentes ni gestiona sus credenciales.

## Markdown/PDF

`<leader>mp` genera el PDF real y `<leader>mv` lo genera y abre en el visor
externo. Cabecera y pie usan `module`, `centre` y `teacher` del YAML. Véase
[Markdown/PDF](docs/markdown-pdf.md).

## LSP

HTML incluye validación local de atributos, ids duplicados y cierres incorrectos,
también antes de guardar. Los errores aparecen subrayados; `gl` muestra el
detalle y `[d` / `]d` permiten recorrerlos. Se instala con las herramientas web.

LuaLS 3.19.0, los servidores web fijados, Pyright 1.1.411 y Bash Language
Server 5.6.0 se instalan de forma aislada, sin Mason ni npm global. Véase
[LSP y completado](docs/lsp.md).

## Mappings principales

| Mapa | Acción |
| --- | --- |
| `<leader>?` / F1 en modo normal | Chuleta de teclas, errores, movimientos y snippets |
| `Espacio r` | Ejecutar este archivo (Bash, Python, JS, TS) en la terminal de abajo |
| `Espacio s` | Insertar plantilla: lista con buscador |
| `Espacio l` | Código: definición, documentación, usos, renombrar, arreglos, formatear |
| `Espacio t` | Texto: duplicar, borrar, copiar, mover, comentar línea… (con su tecla nativa) |
| `Espacio b` | Archivos abiertos: lista, siguiente, anterior, cerrar |
| `Espacio f` | Buscar archivos y texto |
| `Espacio o` | Ortografía: corregir, siguiente falta, añadir palabra |
| `Espacio e` / `Espacio E` | Explorador / localizar el archivo actual |
| `Espacio u` | Opciones: tema, formato al guardar, ortografía |
| `<leader>w` | Guardar |
| `]b` / `[b` / `:bd` | Archivo siguiente / anterior / cerrar archivo |
| `gl` / `[d` / `]d` | Errores de la línea / anterior / siguiente |
| `Ctrl-j` en insertar | Elegir o expandir snippets del lenguaje |
| `Ctrl-j` en insertar, HTML/CSS | También expandir Emmet: `p*5`, `p#average`, `ul>li*3` |
| `Alt-Shift-j/k` / `Cmd-Shift-↓/↑` | Mover líneas o selecciones |
| `<leader>gg` | Lazygit |
| `<leader>mr` / `<leader>md` | Leer Markdown con mdcat / elegir documentación |
| `<leader>mp` / `<leader>mv` | Generar PDF / generar y visualizar |
| `<leader>ac` | Pegar contexto revisable en el agente |
| `<leader>ut` | Elegir Catppuccin, Tokyo Night o Kanagawa |
| `gd`, `grr`, `grn`, `K` | Definición, referencias, rename y hover LSP |
| `Ctrl-h/j/k/l` | Navegar splits de Neovim |
| `Ctrl-a h/j/k/l` | Navegar paneles tmux |
| `Ctrl-a P` | Selector de proyectos tmux |

## Portabilidad

Probado: Debian 13 x86_64. Objetivo no probado: Arch/CachyOS x86_64 y macOS
moderno. Los scripts evitan incompatibilidades BSD evidentes, pero no se afirma
validación real fuera de Debian. Consulta [instalación V1](docs/instalacion.md).

## Seguridad

No se versionan secretos, estado de editores, credenciales ni configuraciones
privadas de agentes. El contexto hacia agentes tiene una barrera preventiva,
no un DLP. El compilador PDF solo está diseñado para Markdown propio y fiable.

## Actualización

Actualizar una versión fijada exige revisar origen, checksum o lockfile,
ejecutar `./scripts/comprobar.sh` y revisar el diff antes de confirmar. No hay
actualizaciones automáticas de plugins, parsers ni LSP.

## Desinstalación

El modo portable no requiere restaurar Neovim: no lo sustituye. Antes de
retirar el entorno, cierre sus procesos y conserve sus proyectos y documentos.
Solo quien activo la V1 mediante `activar.sh` necesita el procedimiento
historico de restauracion. El proyecto nunca borra backups automaticamente.

## Licencia

MIT © 2026 Isaías Fernández Lozano

### TypeScript al guardar

El servidor TypeScript ajusta la sangría e inserta puntos y coma donde corresponde
al guardar archivos TS/TSX. No añade ; a todas las líneas. Espacio uf permite
activar/desactivar el formato al guardar; Espacio lf lo ejecuta manualmente.

### Diffs de lazygit con delta

Si está instalado git-delta (ejecutable delta), Espacio gg y Ctrl-a g lo usan
para mostrar los cambios con resaltado y números de línea. No sustituye lazygit
ni modifica Git global. La tecla | alterna con el diff nativo en lazygit reciente.
El comprobador lo clasifica como recomendado opcional: si falta, Git sigue
funcionando. Los instaladores lo ofrecen cuando procede, siempre con la
confirmación habitual para cambios del sistema.

Paquetes habituales: git-delta en Arch/CachyOS (pacman), Debian/Ubuntu cuando
figure en sus repositorios (apt) y macOS (brew). En WSL2 se instala dentro de
la distribución Linux. No es necesario para ejecutar Neovim.
