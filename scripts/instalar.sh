#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd "$(dirname "$0")" && pwd)
PROJECT_ROOT=$(dirname "$SCRIPT_DIR")
. "$SCRIPT_DIR/lib/versiones.sh"
. "$SCRIPT_DIR/lib/rutas.sh"
. "$SCRIPT_DIR/lib/plataforma.sh"
. "$SCRIPT_DIR/lib/resumen-instalacion.sh"
entorno_fase_actual="opciones y requisitos"
trap entorno_instalacion_salida 0

sistema_auto=0
inicio_sin_pausa=0
for argumento in "$@"; do
  case "$argumento" in
    --sistema) sistema_auto=1 ;;
    -y | --yes) inicio_sin_pausa=1 ;;
    --sin-sistema) sistema_auto=0 ;;
    -h | --help)
      cat <<'EOF'
INSTALACION DE ENTORNO-NVIM

Entorno completo (profesor, desarrollo y Markdown/PDF):
  ./scripts/instalar.sh [--sistema]

Alumnado (DWEC o SI): use este comando en lugar del instalador completo;
pregunta el perfil y lo recuerda:
  ./scripts/instalar-alumno.sh

Solo comprobar la instalacion del alumno:
  ./scripts/instalar-alumno.sh --comprobar

Ayuda detallada del instalador de alumno:
  ./scripts/instalar-alumno.sh --help

Sin opciones comprueba, descarga e instala todo lo que va dentro del
repositorio (Node, Neovim, LuaLS, tree-sitter, plugins, parsers y LSP) sin usar
sudo. Si faltan paquetes imprescindibles del sistema, muestra el comando exacto
y se detiene.

  -y, --yes   Omite la pausa inicial; no autoriza sudo.
  -h, --help  Muestra esta ayuda sin instalar.
  --sin-sistema  Prepara componentes locales sin ofrecer sudo (predeterminado).
  --sistema   Ademas ofrece ejecutar el comando del gestor de paquetes con sudo.
              Siempre muestra el comando y pide confirmacion antes de ejecutar.

Despues de instalar, abra su proyecto desde este repositorio:
  ./bin/entorno-dev --perfil profesor --sin-ia /ruta/a/mi-proyecto
  ./bin/entorno-dev --perfil dwec --sin-ia /ruta/a/mi-proyecto

Para actualizar: git pull --ff-only y repita el instalador elegido.
Lazygit utiliza el paquete del sistema; no se fija su ultima version de GitHub.
Guia de instalacion y perfiles: README.md.
EOF
      exit 0
      ;;
    *)
      printf 'Error: opcion desconocida: %s\n' "$argumento" >&2
      exit 2
      ;;
  esac
done

entorno_banner "Instalación completa"
entorno_confirmar_inicio "Completa: profesor y Markdown/PDF" completa
entorno_fase "Requisitos del sistema"

[ "$(id -u)" -ne 0 ] || {
  printf '%s\n' "Error: no ejecutes este instalador como root." >&2
  exit 1
}

faltan_esenciales=
faltan_opcionales=

# Cada entrada es "clave|etiqueta legible". La categoria decide si bloquea.
anadir_falta() {
  clave=$1
  etiqueta=$2
  categoria=$3
  entrada="$clave|$etiqueta"
  if [ "$categoria" = opcional ]; then
    faltan_opcionales="${faltan_opcionales}
$entrada"
  else
    faltan_esenciales="${faltan_esenciales}
$entrada"
  fi
}

hay_navegador() {
  command -v chromium >/dev/null 2>&1 || command -v google-chrome >/dev/null 2>&1 \
    || command -v brave-browser >/dev/null 2>&1 \
    || [ -x "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser" ] \
    || [ -x "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" ] \
    || [ -x "/Applications/Chromium.app/Contents/MacOS/Chromium" ]
}

hay_compilador() {
  command -v cc >/dev/null 2>&1 || command -v clang >/dev/null 2>&1 || command -v gcc >/dev/null 2>&1
}

clasificar() {
  faltan_esenciales=
  faltan_opcionales=

  command -v git >/dev/null 2>&1 || anadir_falta git Git esencial
  command -v tmux >/dev/null 2>&1 || anadir_falta tmux tmux esencial
  command -v fzf >/dev/null 2>&1 || anadir_falta fzf fzf esencial
  entorno_fd_bin >/dev/null 2>&1 || anadir_falta fd 'fd o fdfind' esencial
  command -v rg >/dev/null 2>&1 || anadir_falta ripgrep ripgrep esencial
  command -v lazygit >/dev/null 2>&1 || anadir_falta lazygit lazygit esencial
  command -v delta >/dev/null 2>&1 || anadir_falta git-delta 'git-delta (diffs de lazygit)' opcional
  command -v curl >/dev/null 2>&1 || anadir_falta curl curl esencial
  command -v tar >/dev/null 2>&1 || anadir_falta tar tar esencial
  command -v unzip >/dev/null 2>&1 || anadir_falta unzip unzip esencial
  hay_compilador || anadir_falta compilador 'compilador (cc, gcc o clang)' esencial
  if ! hay_navegador; then
    if [ "$ENTORNO_IS_WSL" = 1 ]; then
      anadir_falta navegador 'navegador para PDF (opcional en WSL2)' opcional
    else
      anadir_falta navegador 'navegador (Chromium, Chrome o Brave) para PDF' esencial
    fi
  fi
  command -v pandoc >/dev/null 2>&1 || anadir_falta pandoc 'Pandoc (solo Markdown/PDF)' opcional
  command -v pdfinfo >/dev/null 2>&1 || anadir_falta poppler 'poppler-utils (comprobacion de PDF)' opcional
  command -v xdg-open >/dev/null 2>&1 || command -v open >/dev/null 2>&1 \
    || anadir_falta visor 'visor externo de PDF (xdg-open u open)' opcional
}

# Las etiquetas contienen espacios, asi que los elementos se separan solo por
# salto de linea y los bucles usan un IFS restringido a ese caracter.
imprimir_lista() {
  old_ifs=$IFS
  IFS='
'
  for entrada in $1; do
    [ -n "$entrada" ] || continue
    printf '  - %s\n' "${entrada#*|}"
  done
  IFS=$old_ifs
}

paquetes_de() {
  paquetes=
  old_ifs=$IFS
  IFS='
'
  for entrada in $1; do
    clave=${entrada%%|*}
    [ -n "$clave" ] || continue
    paquete=$(entorno_paquete_sistema "$clave")
    [ -n "$paquete" ] || continue
    case " $paquetes " in
      *" $paquete "*) ;;
      *) paquetes="$paquetes $paquete" ;;
    esac
  done
  IFS=$old_ifs
  printf '%s\n' "${paquetes# }"
}

ejecutar_comando_sistema() {
  comando=$1
  printf '\nSe va a ejecutar:\n  %s\n' "$comando"
  printf '¿Continuar? [s/N]: '
  respuesta=
  if [ -r /dev/tty ]; then
    read -r respuesta < /dev/tty || respuesta=
  fi
  printf '\n'
  case "$respuesta" in
    s | S | si | Si | SI | y | Y) ;;
    *)
      printf '%s\n' "Cancelado. No se ha modificado el sistema." >&2
      return 1
      ;;
  esac
  sh -c "$comando"
}

clasificar

if [ -n "$faltan_esenciales" ] || { [ "$sistema_auto" = 1 ] && [ -n "$faltan_opcionales" ]; }; then
  if [ -n "$faltan_esenciales" ]; then
    printf '\nImprescindibles que faltan:\n'
    imprimir_lista "$faltan_esenciales"
  fi
  if [ -n "$faltan_opcionales" ]; then
    printf '\nOpcionales que faltan (no bloquean):\n'
    imprimir_lista "$faltan_opcionales"
  fi

  paquetes=$(paquetes_de "$faltan_esenciales")
  if [ "$sistema_auto" = 1 ] && [ -n "$faltan_opcionales" ]; then
    opcionales=$(paquetes_de "$faltan_opcionales")
    [ -z "$opcionales" ] || paquetes="$paquetes $opcionales"
  fi
  paquetes=${paquetes# }

  if [ -n "$paquetes" ]; then
    comando=$(entorno_comando_sistema $paquetes)
    if [ "$sistema_auto" = 1 ]; then
      ejecutar_comando_sistema "$comando" || true
      clasificar
    else
      printf '\nResuelvelo con:\n  %s\n' "$comando"
      printf '%s\n' "O deja que el instalador lo haga por ti: ./scripts/instalar.sh --sistema"
    fi
  elif [ "$ENTORNO_DISTRO" = macos ] && [ "$sistema_auto" = 1 ]; then
    printf '\nEn macOS instala las herramientas de linea de comandos con:\n  xcode-select --install\n'
  fi

  if [ -n "$faltan_esenciales" ]; then
    printf '\nSiguen faltando imprescindibles. No se ha descargado nada del repositorio.\n' >&2
    exit 1
  fi
fi

if [ -n "$faltan_opcionales" ]; then
  printf '\nAviso: faltan opcionales; el entorno funcionara sin ellos:\n'
  imprimir_lista "$faltan_opcionales"
fi

# Node no se exige al sistema: se descarga una version LTS fijada y verificada
# dentro de .tools/. Solo si esa plataforma carece de artefacto se usa el Node
# del sistema, que entonces debe ser >=24 <25 y traer Corepack.
entorno_fase "Node local"
if ! "$SCRIPT_DIR/instalar-node.sh"; then
  printf '%s\n' "Aviso: no se pudo preparar el Node vendorizado; se intentara el del sistema." >&2
fi
entorno_preferir_node_vendor

if ! command -v node >/dev/null 2>&1; then
  printf '%s\n' "Error: se requiere Node >=$ENTORNO_NODE_MAJOR <$((ENTORNO_NODE_MAJOR + 1)) con Corepack." >&2
  printf '%s\n' "Ejecuta scripts/instalar-node.sh en una plataforma soportada." >&2
  exit 1
fi
compatible=$(node -p "const [a,b]=process.versions.node.split('.').map(Number); Number(a === $ENTORNO_NODE_MAJOR && b >= $ENTORNO_NODE_MIN_MINOR)")
[ "$compatible" = 1 ] || {
  printf 'Error: se requiere Node >=%s.%s <%s; encontrado %s.\n' \
    "$ENTORNO_NODE_MAJOR" "$ENTORNO_NODE_MIN_MINOR" "$((ENTORNO_NODE_MAJOR + 1))" "$(node --version)" >&2
  exit 1
}
command -v corepack >/dev/null 2>&1 || {
  printf '%s\n' "Error: el Node activo no incluye Corepack." >&2
  exit 1
}

entorno_fase "Neovim y LuaLS"
if [ "$ENTORNO_OS" = Darwin ]; then
  NVIM_BIN=${NVIM_BIN:-"$(command -v nvim 2>/dev/null || true)"}
  LUALS_BIN=${LUALS_BIN:-"$(command -v lua-language-server 2>/dev/null || true)"}
  [ -n "$NVIM_BIN" ] || { printf '%s\n' "Error: Neovim no esta disponible en PATH." >&2; exit 1; }
  [ -n "$LUALS_BIN" ] || { printf '%s\n' "Error: LuaLS no esta disponible en PATH." >&2; exit 1; }
  [ -x "$NVIM_BIN" ] && [ "$("$NVIM_BIN" --version | sed -n '1s/^NVIM v//p')" = "$ENTORNO_NVIM_VERSION" ] || {
    printf 'Error: NVIM_BIN no corresponde a Neovim %s.\n' "$ENTORNO_NVIM_VERSION" >&2; exit 1;
  }
  [ -x "$LUALS_BIN" ] && [ "$("$LUALS_BIN" --version 2>/dev/null)" = "$ENTORNO_LUALS_VERSION" ] || {
    printf 'Error: LUALS_BIN no corresponde a LuaLS %s.\n' "$ENTORNO_LUALS_VERSION" >&2; exit 1;
  }
else
  "$SCRIPT_DIR/instalar-neovim.sh"
  "$SCRIPT_DIR/instalar-luals.sh"
fi
entorno_fase "Tree-sitter"
"$SCRIPT_DIR/instalar-tree-sitter.sh"
entorno_fase "Servidores web"
"$SCRIPT_DIR/instalar-lsp-web.sh"
entorno_fase "Servidor Python"
"$SCRIPT_DIR/instalar-lsp-python.sh"
entorno_fase "Servidor Bash"
"$SCRIPT_DIR/instalar-lsp-bash.sh"
entorno_fase "Servidores Docker"
"$SCRIPT_DIR/instalar-lsp-docker.sh"
entorno_fase "Plugins fijados"
"$SCRIPT_DIR/instalar-plugins.sh"
entorno_fase "Diccionario de ortografía"
entorno_ortografia_ok=1
"$SCRIPT_DIR/instalar-ortografia.sh" || entorno_ortografia_ok=0
entorno_fase "Parsers"
"$SCRIPT_DIR/instalar-parsers.sh"
entorno_fase "Comprobación final de requisitos"
"$SCRIPT_DIR/comprobar-requisitos.sh"
entorno_fase "Lanzador entorno-dev"
entorno_lanzador_ok=1
"$SCRIPT_DIR/instalar-entorno-dev.sh" || entorno_lanzador_ok=0
entorno_resumen_instalacion profesor completa

# Consentimiento separado: --yes no autoriza cambiar la shell.
sh "$SCRIPT_DIR/configurar-path.sh"
