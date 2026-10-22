#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH='' cd "$(dirname "$0")" && pwd)
PROJECT_ROOT=$(dirname "$SCRIPT_DIR")
. "$SCRIPT_DIR/lib/versiones.sh"
. "$SCRIPT_DIR/lib/rutas.sh"
. "$SCRIPT_DIR/lib/plataforma.sh"
. "$SCRIPT_DIR/lib/resumen-instalacion.sh"
entorno_fase_actual="opciones y requisitos"

# preguntar: si faltan paquetes y hay terminal, se ofrece instalarlos.
# si: igual, pero explicito (--sistema). no: nunca usa sudo (--sin-sistema).
sistema=preguntar
inicio_sin_pausa=0
solo_comprobar=0
perfil=alumno
# Perfil de la ultima instalacion: lo reutilizan este instalador y entorno-dev.
PERFIL_GUARDADO=${ENTORNO_PERFIL_GUARDADO:-"$PROJECT_ROOT/.xdg/perfil-alumno"}

mostrar_logo() {
  entorno_banner "Instalación para alumnado"
}

uso() {
  cat <<'EOF'
USO
  ./scripts/instalar-alumno.sh

  Prepara el entorno completo del alumnado: HTML, CSS, JavaScript,
  TypeScript, React, Tailwind, Bash, Python, Dockerfile y Docker Compose.
  Detecta Linux x86_64 y ARM64, incluido Windows con WSL2.
  Si faltan programas del sistema, te ofrecerá instalarlos. Para
  actualizar más adelante: ./scripts/actualizar.sh

OPCIONES (no son obligatorias)
  --comprobar        solo revisa la instalación; no descarga ni cambia nada
  --sin-sistema      no instala paquetes del sistema ni usa sudo
  --sistema          acepta la opción antigua; equivale al comportamiento normal
  --perfil dwec|si   se aceptan por compatibilidad; instalan lo mismo
  -y, --yes          empieza sin pedir Enter (no autoriza sudo)
  -h, --help         muestra esta ayuda

DESPUÉS DE INSTALAR
  cd /ruta/a/mi-proyecto
  entorno-dev .

Instalación completa del profesor (Markdown/PDF): ./scripts/instalar.sh
Más ayuda: docs/alumno.md
EOF
}

error_uso() {
  printf '\nError: %s\n' "$1" >&2
  printf '%s\n' 'Lo más sencillo es ejecutar sin opciones:' \
    '  ./scripts/instalar-alumno.sh' 'Ayuda: ./scripts/instalar-alumno.sh --help' >&2
  trap - 0
  exit 2
}

# Perfil único; dwec y si se aceptan por compatibilidad con guías antiguas.
perfil_valido() {
  case "$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')" in
    alumno | dwec | web | si | sistemas) return 0 ;;
    *) return 1 ;;
  esac
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --perfil)
      [ "$#" -ge 2 ] || error_uso 'falta el nombre del perfil después de --perfil.'
      perfil_valido "$2" || error_uso "perfil desconocido: $2."
      shift
      ;;
    --perfil=*) perfil_valido "${1#--perfil=}" || error_uso "perfil desconocido: ${1#--perfil=}." ;;
    alumno | dwec | DWEC | si | SI | web | sistemas) ;;
    --sistema) sistema=si ;;
    --sin-sistema) sistema=no ;;
    -y | --yes) inicio_sin_pausa=1 ;;
    --comprobar) solo_comprobar=1 ;;
    -h | --help | --ayuda) mostrar_logo; uso; exit 0 ;;
    *) error_uso "opción desconocida: $1" ;;
  esac
  shift
done

[ "$(id -u)" -ne 0 ] || {
  printf '%s\n' 'Error: no ejecutes este instalador como root ni con sudo.' \
    'Ejecútalo como tu usuario normal: ./scripts/instalar-alumno.sh' \
    'Si hace falta sudo para algún paquete, el instalador te lo pedirá.' >&2
  exit 1
}

case "$ENTORNO_OS:$ENTORNO_ARCH" in
  Linux:x86_64 | Linux:aarch64 | Linux:arm64) ;;
  *)
    printf 'Error: el instalador de alumnado admite Linux x86_64 y ARM64 (también WSL2); detectado %s %s.\n' \
      "$ENTORNO_OS" "$ENTORNO_ARCH" >&2
    exit 1
    ;;
esac

# Los errores de uso ya se explican solos; desde aqui se resume cualquier fallo.
trap entorno_instalacion_salida 0
mostrar_logo

printf '\nPerfil: alumno (web, Bash, Python y Docker)\n'
printf 'Sistema: %s %s' "$ENTORNO_DISTRO" "$ENTORNO_ARCH"
[ "$ENTORNO_IS_WSL" = 1 ] && printf ' (WSL2)'
printf '\n'

if entorno_ruta_windows_wsl "$PROJECT_ROOT"; then
  printf '\n'
  entorno_explicar_ruta_windows "$PROJECT_ROOT"
  if [ "$solo_comprobar" -eq 0 ] && [ -t 0 ]; then
    printf '%s' '¿Continuar aquí de todos modos? [s/N]: '
    IFS= read -r respuesta_ruta || respuesta_ruta=
    case "$respuesta_ruta" in
      s | S | si | Si | SI | sí | Sí) ;;
      *) printf '%s\n' 'Cancelado. No se ha instalado nada.'; exit 0 ;;
    esac
  fi
fi

if [ "$solo_comprobar" -eq 1 ]; then
  printf '\n%s\n' 'Modo COMPROBACIÓN: solo se revisa el estado; no se instala nada.'
else
  printf '\n%s\n' 'QUÉ VA A PASAR'
  printf '%s\n' \
    '  1. Se revisan los programas del sistema necesarios (git, tmux, fzf...).' \
    '  2. Se descargan Neovim, Node, plugins y servidores de lenguaje dentro de' \
    '     esta carpeta, con versiones fijadas y verificadas.' \
    '  3. Se prepara el comando entorno-dev para abrir tus proyectos.'
  case "$sistema" in
    no) printf '%s\n' '  Con --sin-sistema: si falta algún programa, se indicará cómo instalarlo.' ;;
    *) printf '%s\n' '  Si falta algún programa del sistema, se te preguntará antes de instalarlo.' ;;
  esac
  printf '%s\n' '  No cambia tu Neovim ni tu tmux habituales.'
  if [ "$inicio_sin_pausa" -eq 0 ]; then
    [ -t 0 ] || error_uso 'no hay terminal para confirmar. Usa --yes para empezar sin pausa.'
    printf '\n%s' 'Pulsa Enter para comenzar (Ctrl+C cancela): '
    IFS= read -r inicio_respuesta || exit 1
    if [ -n "$inicio_respuesta" ]; then
      printf '%s\n' 'Cancelado: solo Enter confirma el inicio.'
      exit 0
    fi
  fi
fi

herramientas='git tmux curl tar xz fzf rg shellcheck python3'
faltan=
for herramienta in $herramientas; do
  command -v "$herramienta" >/dev/null 2>&1 || faltan="$faltan $herramienta"
done
entorno_fd_bin >/dev/null 2>&1 || faltan="$faltan fd"
[ -s /etc/ssl/certs/ca-certificates.crt ] || faltan="$faltan ca-certificates"
faltan=${faltan# }

# Recomendados: formato automático de Bash (shfmt) y Python (ruff).
# Solo se ofrecen si el gestor de paquetes los tiene; nunca bloquean.
paquete_disponible() {
  case "$ENTORNO_DISTRO" in
    debian | ubuntu | pop) apt-cache show "$1" >/dev/null 2>&1 ;;
    arch | cachyos | omarchy) pacman -Si "$1" >/dev/null 2>&1 ;;
    *) return 1 ;;
  esac
}
opcionales=
if [ "$solo_comprobar" -eq 0 ]; then
  for opcional in shfmt ruff; do
    command -v "$opcional" >/dev/null 2>&1 && continue
    if paquete_disponible "$opcional"; then opcionales="$opcionales $opcional"; fi
  done
fi
opcionales=${opcionales# }

if [ -z "$faltan" ] && [ -n "$opcionales" ]; then
  entorno_fase "Programas recomendados"
  printf 'Recomendados para formatear al guardar: %s\n' "$opcionales"
  case "$ENTORNO_DISTRO" in
    arch | cachyos | omarchy) comando_opc="sudo pacman -S --needed $opcionales" ;;
    *) comando_opc="sudo apt-get install -y $opcionales" ;;
  esac
  printf 'Comando: %s\n' "$comando_opc"
  if [ "$sistema" != no ] && [ -t 0 ]; then
    printf '%s' '¿Instalarlos ahora? Se te pedirá tu contraseña (Enter o s = sí; n = no): '
    IFS= read -r respuesta_opc || respuesta_opc=n
    case "$respuesta_opc" in
      '' | s | S | si | Si | SI | sí | Sí | y | Y)
        sh -c "$comando_opc" || printf '%s\n' 'AVISO: no se instalaron; el entorno funciona sin ellos.' ;;
      *) printf '%s\n' 'Omitidos: el entorno funciona sin ellos.' ;;
    esac
  else
    printf '%s\n' 'Omitidos: el entorno funciona sin ellos.'
  fi
fi
if [ -n "$faltan" ] && [ -n "$opcionales" ]; then
  faltan="$faltan $opcionales"
fi

if [ -n "$faltan" ]; then
  entorno_fase "Programas del sistema"
  printf 'Faltan estos programas del sistema: %s\n' "$faltan"
  case "$ENTORNO_DISTRO" in
    debian | ubuntu | pop)
      paquetes=
      for herramienta in $faltan; do
        case "$herramienta" in
          fd) paquetes="$paquetes fd-find" ;;
          rg) paquetes="$paquetes ripgrep" ;;
          xz) paquetes="$paquetes xz-utils" ;;
          *) paquetes="$paquetes $herramienta" ;;
        esac
      done
      comando="sudo apt-get update && sudo apt-get install -y${paquetes} ca-certificates"
      ;;
    arch | cachyos | omarchy)
      paquetes=
      for herramienta in $faltan; do
        case "$herramienta" in
          rg) paquetes="$paquetes ripgrep" ;;
          python3) paquetes="$paquetes python" ;;
          *) paquetes="$paquetes $herramienta" ;;
        esac
      done
      comando="sudo pacman -S --needed${paquetes} ca-certificates"
      ;;
    *)
      printf '%s\n' 'Instálalos con el gestor de paquetes de tu distribución y repite:' \
        '  ./scripts/instalar-alumno.sh' >&2
      exit 1
      ;;
  esac

  printf 'Comando para instalarlos:\n  %s\n' "$comando"
  if [ "$solo_comprobar" -eq 1 ] || [ "$sistema" = no ] || [ ! -r /dev/tty ] \
    || { [ "$sistema" = preguntar ] && [ ! -t 0 ]; }; then
    printf '\n%s\n' 'No se ha modificado el sistema.' >&2
    printf '%s\n' 'Ejecuta ese comando (o pide ayuda al profesor) y repite:' \
      '  ./scripts/instalar-alumno.sh' >&2
    exit 1
  fi

  case "$ENTORNO_DISTRO" in
    debian | ubuntu | pop)
      command -v apt-get >/dev/null 2>&1 || {
        printf '%s\n' 'Error: apt-get no está disponible en esta instalación Debian/Ubuntu.' >&2
        exit 1
      }
      command -v sudo >/dev/null 2>&1 || {
        printf '%s\n' 'Error: falta sudo. Pide al profesor o administrador que instale los paquetes mostrados.' >&2
        exit 1
      }
      ;;
  esac

  printf '\n%s\n' '¿Instalarlos ahora? Se te pedirá tu contraseña de Linux (sudo).'
  printf '%s' 'Enter o s = sí; n = no: '
  respuesta=
  if [ -t 0 ]; then
    read -r respuesta || respuesta=n
  else
    read -r respuesta < /dev/tty 2>/dev/null || respuesta=n
  fi
  case "$respuesta" in
    '' | s | S | si | Si | SI | sí | Sí | y | Y) ;;
    *)
      printf '%s\n' 'No se ha modificado el sistema. Cuando los instales, repite:' \
        '  ./scripts/instalar-alumno.sh' >&2
      exit 1
      ;;
  esac
  sh -c "$comando"
  for herramienta in $herramientas; do
    command -v "$herramienta" >/dev/null 2>&1 || {
      printf 'Error: %s sigue sin estar disponible.\n' "$herramienta" >&2
      exit 1
    }
  done
  entorno_fd_bin >/dev/null 2>&1 || { printf '%s\n' "Error: fd/fdfind sigue sin estar disponible." >&2; exit 1; }
  [ -s /etc/ssl/certs/ca-certificates.crt ] || {
    printf '%s\n' 'Error: siguen faltando los certificados TLS del sistema.' >&2
    exit 1
  }
fi

entorno_fase "Neovim local"
NVIM_LOCAL="$ENTORNO_TOOLS_ROOT/nvim-$ENTORNO_NVIM_VERSION/bin/nvim"
if [ -x "$NVIM_LOCAL" ]; then
  printf 'OK: Neovim local %s\n' "$NVIM_LOCAL"
elif [ "$solo_comprobar" -eq 1 ]; then
  printf 'FALTA: Neovim local; ejecuta ./scripts/instalar-alumno.sh\n' >&2
  exit 1
else
  "$SCRIPT_DIR/instalar-neovim.sh"
fi

entorno_fase "Integridad de Neovim"
. "$SCRIPT_DIR/lib/comun.sh"
entorno_verificar_sha256 "$NVIM_LOCAL" "$ENTORNO_NVIM_PLATFORM_BINARY_SHA256"

version_instalada=$("$NVIM_LOCAL" --version | sed -n '1s/^NVIM v//p')
[ "$version_instalada" = "$ENTORNO_NVIM_VERSION" ] || {
  printf 'Error: se esperaba Neovim %s y se encontro %s.\n' \
    "$ENTORNO_NVIM_VERSION" "${version_instalada:-desconocido}" >&2
  exit 1
}

if [ "$solo_comprobar" -eq 0 ]; then
  entorno_fase "Node"
  "$SCRIPT_DIR/instalar-node.sh"
  entorno_fase "Servidores web (HTML, CSS, JS, TS, React, Tailwind)"
  ENTORNO_SIN_FIXTURES=1 "$SCRIPT_DIR/instalar-lsp-web.sh"
  entorno_fase "Servidores de Bash y Python"
  "$SCRIPT_DIR/instalar-lsp-bash.sh"
  "$SCRIPT_DIR/instalar-lsp-python.sh"
  entorno_fase "Servidores de Docker"
  "$SCRIPT_DIR/instalar-lsp-docker.sh"
fi

if [ "$solo_comprobar" -eq 1 ]; then
  plugins_faltan=0
  while IFS=' ' read -r plugin commit; do
    [ -n "$plugin" ] || continue
    actual=$(git -C "${NVIM_XDG_ROOT:-$PROJECT_ROOT/.xdg/$ENTORNO_NVIM_VERSION}/data/nvim/lazy/$plugin" rev-parse HEAD 2>/dev/null || true)
    [ "$actual" = "$commit" ] || plugins_faltan=1
  done <<EOF
$(sed -n 's/^[[:space:]]*"\([^"]*\)":.*"commit": "\([0-9a-f]*\)".*/\1 \2/p' "$PROJECT_ROOT/nvim/lazy-lock.json")
EOF
  [ "$plugins_faltan" -eq 0 ] || {
    printf 'FALTA: plugins fijados; ejecuta ./scripts/instalar-alumno.sh\n' >&2
    exit 1
  }
  NODE_LOCAL=$(entorno_node_dir)/bin/node
  [ -x "$NODE_LOCAL" ] && [ "$("$NODE_LOCAL" --version)" = "v$ENTORNO_NODE_VERSION" ] \
    || { printf '%s\n' "FALTA: Node local verificado." >&2; exit 1; }
  WEB_LSP_BIN="$PROJECT_ROOT/tools/lsp-web/node_modules/.bin"
  for ejecutable in typescript-language-server vscode-html-language-server \
    vscode-css-language-server vscode-json-language-server tailwindcss-language-server
  do
    [ -x "$WEB_LSP_BIN/$ejecutable" ] || {
      printf 'FALTA: servidor web %s; ejecuta ./scripts/instalar-alumno.sh\n' "$ejecutable" >&2
      exit 1
    }
  done
  BASHLS_LOCAL="$PROJECT_ROOT/tools/lsp-bash/node_modules/.bin/bash-language-server"
  PYRIGHT_LOCAL="$PROJECT_ROOT/tools/lsp-python/node_modules/.bin/pyright-langserver"
  [ -x "$BASHLS_LOCAL" ] || { printf '%s\n' "FALTA: Bash Language Server; ejecuta ./scripts/instalar-alumno.sh" >&2; exit 1; }
  [ -x "$PYRIGHT_LOCAL" ] || { printf '%s\n' "FALTA: Pyright; ejecuta ./scripts/instalar-alumno.sh" >&2; exit 1; }
  for ejecutable in docker-langserver docker-compose-langserver; do
    [ -x "$PROJECT_ROOT/tools/lsp-docker/node_modules/.bin/$ejecutable" ] \
      || { printf 'FALTA: %s; repite ./scripts/instalar-alumno.sh\n' "$ejecutable" >&2; exit 1; }
  done
  if [ -f "${NVIM_XDG_ROOT:-$PROJECT_ROOT/.xdg/$ENTORNO_NVIM_VERSION}/data/nvim/site/spell/es.utf-8.spl" ]; then
    printf '%s\n' 'OK: diccionario español de ortografía.'
  else
    printf '%s\n' 'AVISO: falta el diccionario español; se corrige solo en inglés. Repite el instalador.'
  fi
  printf '%s\n' 'OK: entorno del alumnado completo (web, Bash, Python, Docker), tmux, búsqueda, Node, Neovim y plugins.'
  exit 0
fi

entorno_fase "Plugins fijados"
ENTORNO_PERFIL="$perfil" ENTORNO_IA=0 ENTORNO_SIN_LISTEN=1 NVIM_BIN="$NVIM_LOCAL" \
  "$SCRIPT_DIR/instalar-plugins.sh"
entorno_fase "Diccionario de ortografía"
entorno_ortografia_ok=1
"$SCRIPT_DIR/instalar-ortografia.sh" || entorno_ortografia_ok=0
entorno_fase "Arranque de Neovim"
ENTORNO_PERFIL="$perfil" ENTORNO_IA=0 ENTORNO_SIN_LISTEN=1 NVIM_BIN="$NVIM_LOCAL" \
  "$SCRIPT_DIR/arrancar.sh" --headless "+lua if vim.v.errmsg ~= '' then vim.api.nvim_err_writeln(vim.v.errmsg); vim.cmd('cquit 1') end; print('OK: Neovim alumno arranca')" +qa
printf '\n'
entorno_fase "Lanzador entorno-dev"
entorno_lanzador_ok=1
"$SCRIPT_DIR/instalar-entorno-dev.sh" || entorno_lanzador_ok=0

path_preparado=0
case ":$PATH:" in
  *":$HOME/.local/bin:"*) path_preparado=1 ;;
esac

mkdir -p "$(dirname "$PERFIL_GUARDADO")"
printf '%s\n' "$perfil" > "$PERFIL_GUARDADO"

entorno_resumen_instalacion "$perfil" alumnado

if [ "$path_preparado" -eq 0 ]; then
  cat <<'EOF'

Tu shell actual todavia no incluye ~/.local/bin en PATH. Activalo ahora con:
  export PATH="$HOME/.local/bin:$PATH"

Despues podras ejecutar directamente `entorno-dev`. Las terminales nuevas de
Ubuntu suelen incorporar ~/.local/bin automaticamente una vez que existe.
EOF
fi

# Consentimiento separado: --yes no autoriza cambiar la shell.
sh "$SCRIPT_DIR/configurar-path.sh"
