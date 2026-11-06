#!/usr/bin/env bash
# mdcat directo: sin less, sin forzar ANSI y sin tocar configuraciones globales.
set -eu

fail() { printf 'Error: %s\n' "$*" >&2; exit 1; }

if [ "${1:-}" = --view ]; then
  [ "$#" -ge 2 ] || fail 'falta el documento'
  file=$2
  origin=${3:-}
  command -v mdcat >/dev/null 2>&1 || fail 'mdcat no está instalado'
  [ -f "$file" ] && [ -r "$file" ] || fail "no se puede leer: $file"
  cd -- "$(dirname -- "$file")"
  while :; do
    # Solo recursos locales. -P evita que la configuración del paginador cambie
    # el comportamiento; el resto conserva la detección de terminal de mdcat.
    printf '\033[H\033[2J'
    if [ -n "${TMUX:-}" ] && [ -n "${TMUX_PANE:-}" ]; then
      tmux clear-history -t "$TMUX_PANE" 2>/dev/null || :
    fi
    mdcat --local -P -- "$file" || printf '\nNo se pudo representar el documento.\n' >&2
    printf '\n[docs] r: recargar | q: cerrar | desplazar: rueda o Ctrl-a [ en tmux\n'
    # mdcat imprime hasta el final. En documentos largos, situar la vista al
    # inicio del historial propio; no usar un paginador que elimine imágenes.
    if [ -n "${TMUX:-}" ] && [ -n "${TMUX_PANE:-}" ]; then
      history=$(tmux display-message -p -t "$TMUX_PANE" '#{history_size}' 2>/dev/null) || history=0
      if [ "${history:-0}" -gt 0 ]; then
        tmux copy-mode -t "$TMUX_PANE"
        tmux send-keys -t "$TMUX_PANE" -X history-top
      fi
    fi
    while :; do
      IFS= read -rsn1 key || exit 0
      case "$key" in
        r) break ;;
        q)
          if [ -n "$origin" ]; then
            tmux select-window -t "$origin" 2>/dev/null || :
            tmux select-pane -t "$origin" 2>/dev/null || :
          fi
          exit 0
          ;;
      esac
    done
  done
fi

[ "${1:-}" = --open ] && [ "$#" -eq 3 ] || fail 'uso: markdown-view.sh --open PANEL DOCUMENTO'
origin=$2
file=$3
[ -n "${TMUX:-}" ] && [ -n "$origin" ] || fail 'no se pudo identificar el panel tmux'
command -v mdcat >/dev/null 2>&1 || fail 'mdcat no está instalado'
[ -f "$file" ] && [ -r "$file" ] || fail "no se puede leer: $file"
session=$(tmux display-message -p -t "$origin" '#{session_id}') || fail 'sesión no disponible'
self=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/markdown-view.sh
windows=$(tmux list-windows -t "$session" -F '#{window_id} #{@entorno_window_role}')
docs=
while read -r window role; do
  [ "$role" = docs ] || continue
  [ -z "$docs" ] || fail 'hay varias ventanas de documentación en esta sesión'
  docs=$window
done <<< "$windows"

if [ -n "$docs" ]; then
  tmux respawn-window -k -t "$docs" -c "$(dirname -- "$file")" bash "$self" --view "$file" "$origin"
else
  docs=$(tmux new-window -d -P -F '#{window_id}' -t "$session:" -n docs \
    -c "$(dirname -- "$file")" bash "$self" --view "$file" "$origin")
  tmux set-option -w -t "$docs" @entorno_window_role docs
fi
tmux select-window -t "$docs"
