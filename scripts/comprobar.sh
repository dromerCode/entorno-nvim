#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd "$(dirname "$0")" && pwd)
PROJECT_ROOT=$(dirname "$SCRIPT_DIR")
. "$SCRIPT_DIR/lib/versiones.sh"
export ENTORNO_PERFIL=profesor
export ENTORNO_IA=1
XDG_ROOT=${NVIM_XDG_ROOT:-"$PROJECT_ROOT/.xdg/$ENTORNO_NVIM_VERSION"}
TEST_FILE=${NVIM_TEST_FILE:-"$PROJECT_ROOT/tests/comprobar_nucleo.lua"}
DASHBOARD_TEST="$PROJECT_ROOT/tests/comprobar_dashboard.lua"

case "$XDG_ROOT" in
  /*) ;;
  *) XDG_ROOT="$PROJECT_ROOT/$XDG_ROOT" ;;
esac

HEALTH_REPORT="$XDG_ROOT/checkhealth.txt"

export ENTORNO_NVIM_HEALTH_REPORT="$HEALTH_REPORT"
export ENTORNO_NVIM_TEST_FILE="$TEST_FILE"
export ENTORNO_NVIM_DASHBOARD_TEST="$DASHBOARD_TEST"
export ENTORNO_NVIM_EXPECTED_VERSION="${NVIM_EXPECTED_VERSION:-}"

"$SCRIPT_DIR/arrancar.sh" --headless \
  "+lua local ok, err = pcall(dofile, vim.env.ENTORNO_NVIM_TEST_FILE); if not ok then vim.api.nvim_err_writeln(err); vim.cmd('cquit 1') end" \
  "+checkhealth" \
  "+lua require('fzf-lua._health').check()" \
  "+lua vim.fn.writefile(vim.api.nvim_buf_get_lines(0, 0, -1, false), vim.env.ENTORNO_NVIM_HEALTH_REPORT)" \
  "+qa"

"$SCRIPT_DIR/arrancar.sh" --headless \
  "+lua local ok, err = pcall(dofile, vim.env.ENTORNO_NVIM_ROOT .. '/tests/comprobar_emmet.lua'); if not ok then vim.api.nvim_err_writeln(err); vim.cmd('cquit 1') end" \
  "+qa!"

"$SCRIPT_DIR/arrancar.sh" --headless \
  "+lua local ok, err = pcall(dofile, vim.env.ENTORNO_NVIM_ROOT .. '/tests/comprobar_html_validation.lua'); if not ok then vim.api.nvim_err_writeln(err); vim.cmd('cquit 1') end" \
  "+qa!"

"$SCRIPT_DIR/arrancar.sh" --headless \
  "+lua local ok, err = pcall(dofile, vim.env.ENTORNO_NVIM_DASHBOARD_TEST); if not ok then vim.api.nvim_err_writeln(err); vim.cmd('cquit 1') end" \
  "+qa"

"$PROJECT_ROOT/tests/comprobar_temas.sh"

"$PROJECT_ROOT/tests/comprobar_tmux.sh"
sh "$PROJECT_ROOT/tests/comprobar_directorio.sh"
"$PROJECT_ROOT/tests/comprobar_activacion.sh"
"$PROJECT_ROOT/tests/comprobar_markdown_pdf.sh"
"$PROJECT_ROOT/tests/comprobar_instalacion.sh"

git -C "$PROJECT_ROOT" check-ignore -q "$XDG_ROOT/state/profesor/nvim/undo/prueba"
git -C "$PROJECT_ROOT" check-ignore -q "$XDG_ROOT/state/profesor/nvim/swap/prueba"
git -C "$PROJECT_ROOT" check-ignore -q "$XDG_ROOT/data/nvim/lazy/lazy.nvim"
git -C "$PROJECT_ROOT" check-ignore -q "$XDG_ROOT/data/nvim/lazy/fzf-lua"
git -C "$PROJECT_ROOT" check-ignore -q "$XDG_ROOT/data/nvim/lazy/catppuccin"
git -C "$PROJECT_ROOT" check-ignore -q "$XDG_ROOT/data/nvim/lazy/tokyonight.nvim"
git -C "$PROJECT_ROOT" check-ignore -q "$XDG_ROOT/data/nvim/lazy/kanagawa.nvim"
git -C "$PROJECT_ROOT" check-ignore -q "$XDG_ROOT/data/nvim/lazy/nvim-tree.lua"
git -C "$PROJECT_ROOT" check-ignore -q "$XDG_ROOT/data/nvim/lazy/nvim-web-devicons"
git -C "$PROJECT_ROOT" check-ignore -q "$XDG_ROOT/data/nvim/lazy/nvim-lspconfig"
git -C "$PROJECT_ROOT" check-ignore -q "$XDG_ROOT/data/nvim/lazy/nvim-treesitter"
git -C "$PROJECT_ROOT" check-ignore -q "$XDG_ROOT/data/nvim/lazy/mini.nvim"
git -C "$PROJECT_ROOT" check-ignore -q "$XDG_ROOT/data/nvim/site/parser/javascript.so"
git -C "$PROJECT_ROOT" check-ignore -q "$PROJECT_ROOT/tools/lsp-web/node_modules/.bin/typescript-language-server"
git -C "$PROJECT_ROOT" check-ignore -q "$PROJECT_ROOT/tools/lsp-python/node_modules/.bin/pyright-langserver"
git -C "$PROJECT_ROOT" check-ignore -q "$PROJECT_ROOT/tests/fixtures/lsp-tailwind-v4/node_modules/tailwindcss"

if [ ! -f "$PROJECT_ROOT/nvim/lazy-lock.json" ]; then
  printf '%s\n' "Error: falta nvim/lazy-lock.json." >&2
  exit 1
fi

if [ ! -f "$PROJECT_ROOT/tools/lsp-web/pnpm-lock.yaml" ]; then
  printf '%s\n' "Error: falta tools/lsp-web/pnpm-lock.yaml." >&2
  exit 1
fi

if [ ! -f "$PROJECT_ROOT/tools/lsp-python/pnpm-lock.yaml" ]; then
  printf '%s\n' "Error: falta tools/lsp-python/pnpm-lock.yaml." >&2
  exit 1
fi

if [ ! -f "$PROJECT_ROOT/tests/fixtures/lsp-tailwind-v4/pnpm-lock.yaml" ]; then
  printf '%s\n' "Error: falta el lockfile del fixture Tailwind v4." >&2
  exit 1
fi

if grep -q "ERROR" "$HEALTH_REPORT"; then
  printf '%s\n' "Error: checkhealth contiene errores. Informe: $HEALTH_REPORT" >&2
  exit 1
fi

printf '\n%s\n' "Comprobacion correcta. Informe: $HEALTH_REPORT"
