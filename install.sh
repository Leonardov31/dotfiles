#!/usr/bin/env bash
#
# Bootstrap this neovim + Ghostty setup on a fresh macOS machine.
#
#   git clone https://github.com/Leonardov31/dotfiles.git ~/dotfiles
#   cd ~/dotfiles && ./install.sh
#
# Safe to re-run: existing config is backed up, never overwritten in place.

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NODE_VERSION="22.23.1"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"

info()  { printf '\033[1;34m==>\033[0m %s\n' "$1"; }
warn()  { printf '\033[1;33m==>\033[0m %s\n' "$1"; }
ok()    { printf '\033[1;32m==>\033[0m %s\n' "$1"; }
die()   { printf '\033[1;31m==>\033[0m %s\n' "$1" >&2; exit 1; }

[[ "$(uname -s)" == "Darwin" ]] || die "This script targets macOS."

# ── 1. Homebrew ───────────────────────────────────────────────────────────────
if ! command -v brew >/dev/null 2>&1; then
  die "Homebrew is not installed. Install it first (it will ask for your
    password, so this script does not do it for you):

      /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"
"
fi

info "Installing packages from Brewfile…"
brew bundle --file="$DOTFILES/Brewfile"
ok "Packages installed."

# ── 2. node, for Mason ────────────────────────────────────────────────────────
# Mason installs vtsls/eslint/prettier/json/yaml/html/css servers via npm.
if command -v asdf >/dev/null 2>&1; then
  if ! asdf plugin list 2>/dev/null | grep -qx nodejs; then
    info "Adding asdf nodejs plugin…"
    asdf plugin add nodejs
  fi
  if ! asdf list nodejs 2>/dev/null | grep -q "$NODE_VERSION"; then
    info "Installing node $NODE_VERSION…"
    asdf install nodejs "$NODE_VERSION"
  fi
  # writes ~/.tool-versions so node resolves in every directory
  asdf set --home nodejs "$NODE_VERSION"
  ok "node $NODE_VERSION set as the home default."
fi

command -v node >/dev/null 2>&1 || warn "node is still not on PATH — Mason will fail to install the JS/TS servers."

# ── 3. Symlink configs ────────────────────────────────────────────────────────
# The repo is the single source of truth; ~/.config entries point back into it,
# so edits made while using the editor are already tracked by git.
link() {
  local src="$1" dest="$2"

  if [[ -L "$dest" ]]; then
    if [[ "$(readlink "$dest")" == "$src" ]]; then
      ok "$dest already linked."
      return
    fi
    rm "$dest"
  elif [[ -e "$dest" ]]; then
    mkdir -p "$BACKUP_DIR"
    warn "$dest exists — moving it to $BACKUP_DIR/"
    mv "$dest" "$BACKUP_DIR/"
  fi

  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
  ok "linked $dest -> $src"
}

info "Linking configs…"
link "$DOTFILES/nvim"    "$HOME/.config/nvim"
link "$DOTFILES/ghostty" "$HOME/.config/ghostty"

# ── 4. Plugins + language servers ─────────────────────────────────────────────
info "Syncing nvim plugins (first run compiles treesitter parsers, be patient)…"
nvim --headless "+Lazy! sync" +qa 2>&1 | tail -3 || true

info "Installing language servers via Mason…"
nvim --headless "+Lazy! load mason.nvim" \
  "+MasonInstall vtsls eslint-lsp prettier json-lsp yaml-language-server html-lsp css-lsp" \
  +qa 2>&1 | tail -3 || warn "Some Mason packages may not have finished — open nvim and run :Mason to check."

ok "Done."
cat <<'EOF'

Next steps
  1. Open Ghostty and confirm the font renders glyphs (no boxes/question marks).
     If the font was just installed, restart Ghostty so it picks it up.
  2. Run `nvim` and then `:checkhealth` — everything relevant should be green.
  3. `:Mason` lists the installed servers; `:LazyExtras` toggles language support.
  4. Flutter: the SDK path is auto-detected from the usual locations
     (see nvim/lua/plugins/flutter.lua). If yours lives elsewhere, add it there.
EOF
