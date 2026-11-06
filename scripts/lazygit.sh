#!/bin/sh
# Añade solo el renderer de delta; no escribe configuración global.
set -eu
command -v lazygit >/dev/null 2>&1 || { printf '%s\n' 'Falta lazygit.' >&2; exit 1; }
if ! command -v delta >/dev/null 2>&1; then
  exec lazygit "$@"
fi
root=$(CDPATH= cd "$(dirname "$0")/.." && pwd)
report=$(lazygit --version 2>/dev/null)
report=${report#*version=}
version=$(printf '%s' "$report" | sed -n 's/^\([0-9][0-9]*\)\.\([0-9][0-9]*\)\..*/\1 \2/p')
major=${version%% *}
minor=${version#* }
case "$major:$minor" in
  *[!0-9:]* | : ) exec lazygit "$@" ;;
esac
if [ "$major" -gt 0 ] || [ "$minor" -ge 64 ]; then
  overlay="$root/config/lazygit-delta.yml"
else
  overlay="$root/config/lazygit-delta-legacy.yml"
fi
configs=${LG_CONFIG_FILE:-}
if [ -z "$configs" ]; then
  directory=$(lazygit --print-config-dir)
  if [ -f "$directory/config.yml" ]; then configs="$directory/config.yml"; fi
fi
# Lazygit separa rutas por comas; no reinterpretar una ruta con esa coma.
case "$overlay" in *,*) exec lazygit "$@" ;; esac
if [ -n "$configs" ]; then configs="$configs,$overlay"; else configs=$overlay; fi
exec lazygit --use-config-file "$configs" "$@"
