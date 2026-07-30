# Brewfile — everything this setup needs.
# Apply with:  brew bundle --file=Brewfile

cask_args appdir: "/Applications"

# ── Terminal ──────────────────────────────────────────────────────────────────
cask "ghostty"
# No Nerd Font cask on purpose: Ghostty's default font is JetBrains Mono and it
# bundles "Symbols Nerd Font" as a fallback, so LazyVim's icons render without
# installing one. See the Font section of ghostty/config.

# ── Editor ────────────────────────────────────────────────────────────────────
brew "neovim"

# Required by LazyVim: ripgrep powers grep/picker, fd powers file finding
brew "ripgrep"
brew "fd"

# ── Tooling reachable from inside nvim ────────────────────────────────────────
# <leader>gg opens lazygit
brew "lazygit"
# SQL linter/formatter. Installed here rather than through Mason, whose pip
# venv build for this package is slow and was failing — see nvim/lua/plugins/sql.lua
brew "sqlfluff"

# ── Version manager ───────────────────────────────────────────────────────────
# Mason shells out to node/npm to install vtsls, eslint, prettier and the
# json/yaml/html/css servers, so a working node is a hard dependency.
brew "asdf"

# ── Git ───────────────────────────────────────────────────────────────────────
brew "gh"
