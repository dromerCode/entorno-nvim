#!/bin/sh
# Regresion del contrato «cd carpeta; entorno-dev .», sin tocar sesiones reales.
set -eu
PROJECT_ROOT=$(CDPATH= cd "$(dirname "$0")/.." && pwd -P)
WORK_DIR=$(mktemp -d "${TMPDIR:-/tmp}/entorno-directorio.XXXXXX")
SOCKET="entorno-directorio-$$"
cleanup() {
  tmux -L "$SOCKET" kill-server 2>/dev/null || true
  rm -rf "$WORK_DIR"
}
trap cleanup EXIT HUP INT TERM
export ENTORNO_TMUX_SOCKET="$SOCKET" ENTORNO_TMUX_NO_ATTACH=1
export ENTORNO_PERFIL=alumno ENTORNO_IA=0
export ENTORNO_EDITOR_COMMAND="$PROJECT_ROOT/tests/fixtures/tmux/fake-nvim.sh"
# No heredar un servidor ni un panel de la terminal desde la que se prueba.
unset TMUX TMUX_PANE
repo="$WORK_DIR/clase con espacios"
exercise="$repo/tema 3/ejercicio 1"
plain="$WORK_DIR/sin git"
mkdir -p "$exercise" "$plain"
git -C "$repo" init -q

check_directory() {
  expected=$(CDPATH= cd "$1" && pwd -P)
  session=$(cd "$1" && "$PROJECT_ROOT/bin/entorno-dev" .)
  actual=$(tmux -L "$SOCKET" show-option -v -t "$session" @entorno_project_root)
  [ "$actual" = "$expected" ] || {
    printf 'Error: se pidio %s pero se abrio %s\n' "$expected" "$actual" >&2
    exit 1
  }
  # Tanto editor como terminal deben iniciar en la carpeta solicitada.
  paths=$(tmux -L "$SOCKET" list-panes -t "=$session" -F '#{pane_current_path}')
  [ "$(printf '%s\n' "$paths" | wc -l)" -eq 2 ]
  while IFS= read -r path; do
    [ "$path" = "$expected" ] || exit 1
  done <<EOF
$paths
EOF
}

check_directory "$repo"
root_session=$session
check_directory "$exercise"
exercise_session=$session
[ "$exercise_session" != "$root_session" ]
check_directory "$plain"
check_directory "$exercise"
[ "$session" = "$exercise_session" ]
printf '%s\n' 'Comprobacion de carpeta explicita correcta (Git, subcarpetas, espacios y reconexion).'
