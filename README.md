# dotfiles

Neovim (LazyVim) + Ghostty setup for macOS.

## Install

```bash
git clone https://github.com/Leonardov31/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./install.sh
```

`install.sh` is idempotent. Anything already at `~/.config/nvim` or
`~/.config/ghostty` is moved to `~/.config-backup-<timestamp>/` rather than
overwritten.

Homebrew itself is the one prerequisite the script won't install, because it
needs your password.

## Layout

```
Brewfile        packages (neovim, ripgrep, fd, lazygit, sqlfluff, ghostty, gh)
install.sh      bootstrap: brew bundle -> node via asdf -> symlinks -> plugin sync
nvim/           symlinked to ~/.config/nvim
ghostty/        symlinked to ~/.config/ghostty
```

The symlinks mean the repo is the source of truth: editing your config while
working on it already edits the tracked files.

## What's configured

**Ghostty** — font settings left at their defaults on purpose. Ghostty's
built-in font is JetBrains Mono and it bundles "Symbols Nerd Font" as a
fallback, so LazyVim's icons render without installing a patched Nerd Font
(`ghostty +show-face --cp=0xF07B` shows which face serves a glyph). That is
Ghostty-specific — Terminal.app and bare iTerm2 do need a Nerd Font installed.

TokyoNight Moon is set to match LazyVim's default colorscheme, so the terminal
and editor backgrounds are the same color. `macos-option-as-alt = left` is
deliberate: the left option key sends Alt/Meta so nvim receives `<M-...>`
chords, while the right option key keeps macOS compose behaviour for typing
accented characters (`option+c` = ç).

**Neovim** — LazyVim v16 on nvim 0.12, with these extras enabled in
`nvim/lua/config/lazy.lua`:

| Extra | Covers |
|---|---|
| `lang.typescript` (vtsls) | TypeScript/JavaScript, Node and React |
| `linting.eslint`, `formatting.prettier` | same |
| `lang.json`, `lang.yaml` | package.json, tsconfig, docker-compose, CI |
| `lang.dart` | Dart/Flutter |
| `lang.sql` | migrations and queries |

Lua support (`lua_ls` + lazydev) ships with LazyVim core, so editing this config
gets completion for the nvim API without any extra.

### Local overrides, and why they exist

Everything in `nvim/lua/plugins/` is a deliberate deviation from stock LazyVim:

- **`web.lua`** — LazyVim has no `lang.html` extra. Adds `html` + `cssls` for
  static HTML/CSS and the CSS side of React projects.
- **`flutter.lua`** — `lang.dart` starts `dartls` through plain lspconfig;
  flutter-tools.nvim starts it too *and* adds `:FlutterRun`/`:FlutterReload`/
  `:FlutterDevices`. Running both attaches two clients to every Dart buffer, so
  lspconfig's `dartls` is disabled and flutter-tools owns it. The SDK path is
  auto-detected across the usual install locations.
- **`sql.lua`** — two fixes. The extra defaults sqlfluff to the `ansi` dialect,
  which flags valid Postgres syntax; both linter and formatter are pointed at
  `postgres`. And conform's builtin sqlfluff sets `require_cwd = true`, so it
  only runs inside a directory containing `.sqlfluff`/`pyproject.toml`/
  `setup.cfg`/`tox.ini` — a project without one silently gets no SQL formatting
  at all. The dialect is passed on the command line, so `require_cwd` is turned
  off.
- **`lazy.lua`** — keeps the built-in `tutor` runtime plugin enabled (the
  LazyVim starter disables it), so `:Tutor` works.

### sqlfluff comes from Homebrew

Not from Mason, whose pip venv build for it is slow and unreliable. `sql.lua`
filters it out of Mason's `ensure_installed` so the two don't fight, and
conform/nvim-lint pick up the Homebrew binary from PATH.

### GitLab merge request review

`nvim/lua/plugins/gitlab.lua` adds `harrisoncramer/gitlab.nvim`: review an MR
without leaving the editor — diff, inline comments, threads, suggestions,
approve, merge.

Worth knowing this is *not* GitLab's official `gitlab.vim`. That plugin is built
around Duo Code Suggestions and cannot review an MR: no list, no diff, no
discussions, no approve — its only MR feature is `:edit <mr-url>` to edit the
description. The two are complementary, not alternatives.

It compiles a Go server on install and on every update, which is why the
Brewfile carries `go`.

Authentication is via a Personal Access Token with the `api` scope, exported
from your shell (`~/.zshrc`, deliberately outside this repo):

```bash
export GITLAB_TOKEN="glpat-..."
export GITLAB_URL="https://gitlab.example.com"   # self-hosted only
```

The plugin also reads a `.gitlab.nvim` file from the project root, and that file
**takes precedence** over the environment. Prefer the env var — a token file
inside a work repo is one `git add -A` away from being committed. If you do use
the file, ignore it globally:

```bash
git config --global core.excludesfile ~/.config/git/ignore
echo '.gitlab.nvim' >> ~/.config/git/ignore
```

Keymaps use the `gl` prefix (unused otherwise): `glc` choose an MR, `glS` review
the current branch, `glA` approve, `glM` merge. Inside the diff, `c` + motion
comments on those lines and `s` + motion writes a suggestion.

### Database UI

`<leader>D` toggles vim-dadbod's UI. Connections are deliberately not stored in
this repo — they'd be credentials in a public file. Per project, drop a
`.lazy.lua` in the project root and gitignore it:

```lua
vim.g.dbs = { local_dev = "postgres://user:pass@localhost:5432/dbname" }
return {}
```

## Note on Node version managers

Mason installs the JS/TS language servers with npm, so nvim needs a working
`node` in whatever directory you launch it from. If you use asdf with
`legacy_version_file = yes`, a project whose `.nvmrc` pins a version you don't
have installed will break `node` in that directory — and with it every
node-based language server. Symptom: no LSP attaches, while other projects are
fine. Either install that version, or override it for the session:

```bash
ASDF_NODEJS_VERSION=22.23.1 nvim .
```

## Day-to-day

| Command | Does |
|---|---|
| `:Tutor` | built-in interactive vim tutorial |
| `:Lazy` | plugin manager; `S` syncs, `U` updates |
| `:LazyExtras` | toggle language/feature extras |
| `:Mason` | manage language servers |
| `:checkhealth` | diagnose a broken setup |
| `cmd+shift+,` | reload Ghostty config in place |

Press `<space>` and wait to get a which-key menu of everything available;
`<space>sk` searches all keymaps.

After changing config, commit from `~/dotfiles` — the symlinks mean the changes
are already staged in the right place.
