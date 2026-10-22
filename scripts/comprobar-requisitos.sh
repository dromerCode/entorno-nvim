#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH='' cd "$(dirname "$0")" && pwd)
PROJECT_ROOT=$(dirname "$SCRIPT_DIR")
. "$SCRIPT_DIR/lib/versiones.sh"
. "$SCRIPT_DIR/lib/comun.sh"
. "$SCRIPT_DIR/lib/rutas.sh"
. "$SCRIPT_DIR/lib/plataforma.sh"
entorno_preferir_node_vendor
ENTORNO_VERSION=$(sed -n '1p' "$PROJECT_ROOT/VERSION")
[ -n "$ENTORNO_VERSION" ] || {
  printf '%s\n' "Error: VERSION esta vacio." >&2
  exit 1
}

USER_HOME=${ENTORNO_NVIM_HOME:-"$HOME"}
XDG_ROOT=${NVIM_XDG_ROOT:-"$PROJECT_ROOT/.xdg/$ENTORNO_NVIM_VERSION"}
DEFAULT_NVIM_BIN="$ENTORNO_TOOLS_ROOT/nvim-$ENTORNO_NVIM_VERSION/bin/nvim"
if [ ! -x "$DEFAULT_NVIM_BIN" ] && [ "$(uname -s)" = Darwin ]; then
  DEFAULT_NVIM_BIN=$(command -v nvim 2>/dev/null || printf '%s' "$DEFAULT_NVIM_BIN")
fi
NVIM_BIN=${NVIM_BIN:-"$DEFAULT_NVIM_BIN"}
TREE_SITTER_BIN=${TREE_SITTER_BIN:-"$ENTORNO_TOOLS_ROOT/tree-sitter-cli-$ENTORNO_TREE_SITTER_VERSION/bin/tree-sitter"}
DEFAULT_LUALS_BIN="$ENTORNO_TOOLS_ROOT/lua-language-server-$ENTORNO_LUALS_VERSION/bin/lua-language-server"
if [ ! -x "$DEFAULT_LUALS_BIN" ] && [ "$(uname -s)" = Darwin ]; then
  DEFAULT_LUALS_BIN=$(command -v lua-language-server 2>/dev/null || printf '%s' "$DEFAULT_LUALS_BIN")
fi
LUALS_BIN=${LUALS_BIN:-"$DEFAULT_LUALS_BIN"}
LSP_WEB_BIN=${LSP_WEB_BIN:-"$PROJECT_ROOT/tools/lsp-web/node_modules/.bin"}
LSP_PYTHON_BIN=${LSP_PYTHON_BIN:-"$PROJECT_ROOT/tools/lsp-python/node_modules/.bin"}
missing=0

ok() { printf 'OK        %-24s %s\n' "$1" "$2"; }
falta() { printf 'FALTA     %-24s %s\n' "$1" "$2"; missing=1; }
opcional() { printf 'OPCIONAL  %-24s %s\n' "$1" "$2"; }

command_required() {
  label=$1
  shift
  for candidate in "$@"; do
    if command -v "$candidate" >/dev/null 2>&1; then
      ok "$label" "$(command -v "$candidate")"
      return
    fi
  done
  falta "$label" "no encontrado ($*)"
}

command_optional() {
  label=$1
  shift
  for candidate in "$@"; do
    if command -v "$candidate" >/dev/null 2>&1; then
      ok "$label" "$(command -v "$candidate")"
      return
    fi
  done
  opcional "$label" "no encontrado ($*)"
}

node_package_matches() {
  package_dir=$1
  package_name=$2
  node -e '
    const fs = require("fs");
    const path = require("path");
    const dir = process.argv[1];
    const name = process.argv[2];
    const manifest = JSON.parse(fs.readFileSync(path.join(dir, "package.json"), "utf8"));
    const expected = (manifest.devDependencies || {})[name];
    const installed = JSON.parse(fs.readFileSync(path.join(dir, "node_modules", ...name.split("/"), "package.json"), "utf8"));
    if (!expected || installed.version !== expected) process.exit(1);
  ' "$package_dir" "$package_name" 2>/dev/null
}

printf 'entorno-nvim v%s - %s %s' "$ENTORNO_VERSION" "$ENTORNO_OS" "$ENTORNO_ARCH"
[ "$ENTORNO_IS_WSL" = 1 ] && printf ' (WSL2)'
printf ' - %s\n\n' "$ENTORNO_DISTRO"
command_required git git
command_required tmux tmux
command_required fzf fzf
command_required fd fd fdfind
command_required ripgrep rg
command_required lazygit lazygit
command_optional Pandoc pandoc
if command -v chromium >/dev/null 2>&1; then
  ok navegador "$(command -v chromium)"
elif command -v google-chrome >/dev/null 2>&1; then
  ok navegador "$(command -v google-chrome)"
elif command -v brave-browser >/dev/null 2>&1; then
  ok navegador "$(command -v brave-browser)"
elif [ -x "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser" ] \
  || [ -x "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" ] \
  || [ -x "/Applications/Chromium.app/Contents/MacOS/Chromium" ]; then
  ok navegador "aplicacion macOS detectada"
elif [ "$ENTORNO_IS_WSL" = 1 ]; then
  opcional navegador "WSL2 sin navegador: el PDF y el visor quedaran deshabilitados"
else
  falta navegador "Chromium, Google Chrome o Brave no encontrado"
fi
command_required curl curl
command_required tar tar
command_required unzip unzip
command_required compilador cc clang gcc
command_optional pdfinfo pdfinfo
command_optional pdftotext pdftotext
command_optional pdftoppm pdftoppm
command_optional "visor PDF" xdg-open open

if command -v node >/dev/null 2>&1; then
  node_origen=sistema
  entorno_node_bin_dir >/dev/null 2>&1 && node_origen=vendorizado
  compatible=$(node -p "const [a,b]=process.versions.node.split('.').map(Number); Number(a === $ENTORNO_NODE_MAJOR && b >= $ENTORNO_NODE_MIN_MINOR)" 2>/dev/null || printf 0)
  if [ "$compatible" = 1 ]; then
    ok "Node compatible" "$(node --version) ($node_origen)"
  else
    falta "Node compatible" "se requiere >=$ENTORNO_NODE_MAJOR <$((ENTORNO_NODE_MAJOR + 1)); ejecuta scripts/instalar-node.sh"
  fi
else
  falta Node "ejecuta scripts/instalar-node.sh"
fi
if command -v corepack >/dev/null 2>&1; then
  ok pnpm "v$ENTORNO_PNPM_VERSION fijado por packageManager; no se requiere global"
else
  falta Corepack "lo incluye el Node vendorizado; ejecuta scripts/instalar-node.sh"
fi

if [ -x "$NVIM_BIN" ] && [ "$("$NVIM_BIN" --version | sed -n '1s/^NVIM v//p')" = "$ENTORNO_NVIM_VERSION" ] \
  && { [ -z "$ENTORNO_NVIM_PLATFORM" ] || [ "$(entorno_sha256 "$NVIM_BIN")" = "$ENTORNO_NVIM_PLATFORM_BINARY_SHA256" ]; }; then
  ok Neovim "$NVIM_BIN ($ENTORNO_NVIM_VERSION)"
else falta Neovim "ejecuta scripts/instalar-neovim.sh"; fi
if [ -x "$TREE_SITTER_BIN" ] && [ "$("$TREE_SITTER_BIN" --version | awk '{ print $2 }')" = "$ENTORNO_TREE_SITTER_VERSION" ] \
  && { [ "$(uname -s):$(uname -m)" != Linux:x86_64 ] || [ "$(entorno_sha256 "$TREE_SITTER_BIN")" = "$ENTORNO_TREE_SITTER_LINUX_X64_BINARY_SHA256" ]; }; then
  ok "tree-sitter CLI" "$TREE_SITTER_BIN ($ENTORNO_TREE_SITTER_VERSION)"
else falta "tree-sitter CLI" "ejecuta scripts/instalar-tree-sitter.sh"; fi
if [ -x "$LUALS_BIN" ] && [ "$("$LUALS_BIN" --version 2>/dev/null)" = "$ENTORNO_LUALS_VERSION" ] \
  && { [ "$(uname -s):$(uname -m)" != Linux:x86_64 ] || [ "$(entorno_sha256 "$LUALS_BIN")" = "$ENTORNO_LUALS_LINUX_X64_BINARY_SHA256" ]; }; then
  ok LuaLS "$LUALS_BIN ($ENTORNO_LUALS_VERSION)"
else falta LuaLS "ejecuta scripts/instalar-luals.sh"; fi

for pair in \
  typescript-language-server:typescript-language-server \
  vscode-html-language-server:vscode-langservers-extracted \
  vscode-css-language-server:vscode-langservers-extracted \
  vscode-json-language-server:vscode-langservers-extracted \
  tailwindcss-language-server:@tailwindcss/language-server
do
  executable=${pair%%:*}
  package=${pair#*:}
  if [ -x "$LSP_WEB_BIN/$executable" ] && node_package_matches "$PROJECT_ROOT/tools/lsp-web" "$package"; then
    ok "$executable" "$LSP_WEB_BIN/$executable"
  else
    falta "$executable" "ejecuta scripts/instalar-lsp-web.sh"
  fi
done
if [ -x "$LSP_PYTHON_BIN/pyright-langserver" ] && node_package_matches "$PROJECT_ROOT/tools/lsp-python" pyright; then
  ok Pyright "$ENTORNO_PYRIGHT_VERSION"
else
  falta Pyright "ejecuta scripts/instalar-lsp-python.sh"
fi
opcional BashLS "aplazado deliberadamente; no se instala"

plugins_missing=0
plugin_count=0
while IFS=' ' read -r plugin commit; do
  [ -n "$plugin" ] || continue
  plugin_count=$((plugin_count + 1))
  plugin_dir="$XDG_ROOT/data/nvim/lazy/$plugin"
  actual=$(git -C "$plugin_dir" rev-parse HEAD 2>/dev/null || true)
  if [ "$actual" != "$commit" ]; then plugins_missing=1; break; fi
done <<EOF
$(sed -n 's/^[[:space:]]*"\([^"]*\)":.*"commit": "\([0-9a-f]*\)".*/\1 \2/p' "$PROJECT_ROOT/nvim/lazy-lock.json")
EOF
if [ "$plugins_missing" -eq 0 ] && [ "$plugin_count" -gt 0 ]; then ok "plugins Neovim" "revisiones de lazy-lock.json instaladas"; else falta "plugins Neovim" "ejecuta scripts/instalar-plugins.sh"; fi

parsers_missing=
for parser in $ENTORNO_PARSERS; do
  [ -f "$XDG_ROOT/data/nvim/site/parser/$parser.so" ] || parsers_missing="$parsers_missing $parser"
done
if [ -z "$parsers_missing" ]; then ok "parsers Tree-sitter" "$ENTORNO_PARSERS"; else falta "parsers Tree-sitter" "faltan:$parsers_missing"; fi

printf '\n'
if [ "$missing" -eq 0 ]; then
  printf '%s\n' "Todos los requisitos obligatorios estan preparados."
  exit 0
fi
printf '%s\n' "Faltan requisitos obligatorios; este comando no ha modificado la maquina." >&2
exit 1
