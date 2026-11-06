#!/bin/sh
set -eu

fail() {
  tmux display-message -t "${origin_pane:-}" "Error: $*" 2>/dev/null || :
  exit 1
}

[ "$#" -eq 1 ] || fail "uso: scripts/tmux-lazygit.sh pane-origen"
origin_pane=$1
[ -n "${TMUX:-}" ] || fail "lazygit debe abrirse dentro de tmux"

session=$(tmux display-message -p -t "$origin_pane" '#{session_id}' 2>/dev/null) ||
  fail "no se pudo identificar la sesion actual"
windows=$(tmux list-windows -t "$session" -F '#{window_id}	#{@entorno_window_role}' 2>/dev/null) ||
  fail "no se pudieron consultar las ventanas de la sesion"

git_window=
git_windows=0
tab=$(printf '\t')
while IFS="$tab" read -r window_id window_role; do
  [ "$window_role" = git ] || continue
  git_window=$window_id
  git_windows=$((git_windows + 1))
done <<EOF
$windows
EOF

[ "$git_windows" -le 1 ] || fail "hay varias ventanas con @entorno_window_role=git"
if [ "$git_windows" -eq 1 ]; then
  tmux select-window -t "$git_window"
  exit 0
fi

lazygit=$(command -v lazygit 2>/dev/null || true)
[ -n "$lazygit" ] && [ -x "$lazygit" ] || fail "lazygit no esta instalado"
project=$(tmux show-option -v -t "$session" @entorno_project_root 2>/dev/null) || project=
[ -n "$project" ] && [ -d "$project" ] || fail "la sesion no tiene un @entorno_project_root valido"

root=$(CDPATH= cd "${0%/*}/.." && pwd)
if command -v delta >/dev/null 2>&1; then
  git_window=$(tmux new-window -P -F '#{window_id}' -t "$session" -n git -c "$project" \
    sh "$root/scripts/lazygit.sh") || fail "no se pudo crear la ventana de lazygit"
else
  git_window=$(tmux new-window -P -F '#{window_id}' -t "$session" -n git -c "$project" "$lazygit") ||
    fail "no se pudo crear la ventana de lazygit"
fi
tmux set-option -w -t "$git_window" @entorno_window_role git
