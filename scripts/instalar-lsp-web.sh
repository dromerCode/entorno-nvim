#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd "$(dirname "$0")" && pwd)
PROJECT_ROOT=$(dirname "$SCRIPT_DIR")
. "$SCRIPT_DIR/lib/versiones.sh"
. "$SCRIPT_DIR/lib/rutas.sh"
. "$SCRIPT_DIR/lib/plataforma.sh"
entorno_preferir_node_vendor
TOOLS_DIR="$PROJECT_ROOT/tools/lsp-web"
TAILWIND_FIXTURE_DIR="$PROJECT_ROOT/tests/fixtures/lsp-tailwind-v4"
XDG_ROOT=${NVIM_XDG_ROOT:-"$PROJECT_ROOT/.xdg/$ENTORNO_NVIM_VERSION"}

case "$XDG_ROOT" in
  /*) ;;
  *) XDG_ROOT="$PROJECT_ROOT/$XDG_ROOT" ;;
esac

if ! command -v node >/dev/null 2>&1 || ! command -v corepack >/dev/null 2>&1; then
  printf '%s\n' "Error: se requieren Node 24 LTS y Corepack." >&2
  exit 1
fi

NODE_COMPATIBLE=$(node -p "const major = Number(process.versions.node.split('.')[0]); Number(major === 24)")
if [ "$NODE_COMPATIBLE" != "1" ]; then
  printf '%s\n' "Error: se requiere Node >=24 <25; version encontrada: $(node --version)" >&2
  exit 1
fi

COREPACK_HOME="$XDG_ROOT/corepack"
PNPM_STORE_DIR="$XDG_ROOT/pnpm/store"
mkdir -p "$COREPACK_HOME" "$PNPM_STORE_DIR"

export COREPACK_HOME

packages_match() {
  package_dir=$1
  node -e '
    const fs = require("fs");
    const path = require("path");
    const dir = process.argv[1];
    const manifest = JSON.parse(fs.readFileSync(path.join(dir, "package.json"), "utf8"));
    for (const [name, expected] of Object.entries(manifest.devDependencies || {})) {
      const installed = JSON.parse(fs.readFileSync(path.join(dir, "node_modules", ...name.split("/"), "package.json"), "utf8"));
      if (installed.version !== expected) process.exit(1);
    }
  ' "$package_dir" 2>/dev/null
}

if packages_match "$TOOLS_DIR"; then
  printf '%s\n' "Servidores LSP web ya instalados con las versiones fijadas."
else
  cd "$TOOLS_DIR"
  corepack "pnpm@$ENTORNO_PNPM_VERSION" install --frozen-lockfile --store-dir "$PNPM_STORE_DIR"
  corepack "pnpm@$ENTORNO_PNPM_VERSION" ignored-builds
fi

for executable in \
  tailwindcss-language-server \
  html-validate \
  prettier \
  typescript-language-server \
  vscode-html-language-server \
  vscode-css-language-server \
  vscode-json-language-server
do
  if [ ! -x "$TOOLS_DIR/node_modules/.bin/$executable" ]; then
    printf '%s\n' "Error: falta el ejecutable $executable." >&2
    exit 1
  fi
done

if [ "${ENTORNO_SIN_FIXTURES:-0}" != 1 ]; then
  if packages_match "$TAILWIND_FIXTURE_DIR"; then
    printf '%s\n' "Fixture Tailwind v4 ya instalado con las versiones fijadas."
  else
    cd "$TAILWIND_FIXTURE_DIR"
    corepack "pnpm@$ENTORNO_PNPM_VERSION" install --frozen-lockfile --store-dir "$PNPM_STORE_DIR"
    corepack "pnpm@$ENTORNO_PNPM_VERSION" ignored-builds
  fi
fi

printf '%s\n' "Servidores LSP web instalados en $TOOLS_DIR/node_modules/.bin"
if [ "${ENTORNO_SIN_FIXTURES:-0}" != 1 ]; then
  printf '%s\n' "Fixture Tailwind v4 instalado en $TAILWIND_FIXTURE_DIR/node_modules"
fi
