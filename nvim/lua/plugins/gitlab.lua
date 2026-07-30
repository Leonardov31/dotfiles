-- GitLab merge request review, inside the editor.
--
-- Note this is NOT GitLab's official `gitlab.vim`. That one is built around Duo
-- Code Suggestions (AI completion) and cannot review: it has no MR list, no
-- diff, no discussions, no approve -- its only MR feature is `:edit <mr-url>`
-- to edit the description. This plugin is the one that implements review.
--
-- Requires Go (>= 1.25.1) to compile the companion server; `build` does that
-- on install and on every update.
--
-- ── Authentication ──────────────────────────────────────────────────────────
-- Set GITLAB_TOKEN in your shell (a Personal Access Token with the `api`
-- scope). Keep it in ~/.zshrc, which is NOT tracked by this repo:
--
--     export GITLAB_TOKEN="glpat-..."
--     export GITLAB_URL="https://gitlab.example.com"   # self-hosted only
--
-- The plugin also reads a `.gitlab.nvim` file from the project root, and that
-- file TAKES PRECEDENCE over the environment. Prefer the env var: a token file
-- sitting in a work repo is one `git add -A` away from being committed. If you
-- ever do use the file, gitignore it globally:
--
--     git config --global core.excludesfile ~/.config/git/ignore
--     echo '.gitlab.nvim' >> ~/.config/git/ignore
--
-- ── Keymaps (plugin defaults, the `gl` prefix is otherwise unused) ───────────
--   glc  choose an MR to review          glS  review the checked-out branch
--   gln  create a comment                glA  approve
--   glM  merge and close
-- Inside the review diff: `c` + motion comments on those lines, `s` + motion
-- creates a suggestion.
return {
  {
    "harrisoncramer/gitlab.nvim",
    -- Entry points. Loading on these keeps it out of startup; once loaded,
    -- setup() registers the full `gl` keymap set.
    keys = {
      { "glc", desc = "GitLab: choose MR to review" },
      { "glS", desc = "GitLab: review current branch" },
    },
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      -- maintained fork, which upstream depends on by name
      "dlyongemallo/diffview.nvim",
      -- Upstream also recommends dressing.nvim and nvim-web-devicons. Both are
      -- omitted on purpose: LazyVim already provides vim.ui.input through
      -- snacks.input, and it mocks nvim-web-devicons via mini.icons
      -- (package.preload), so installing the real ones would shadow that.
    },
    build = function()
      require("gitlab.server").build(true)
    end,
    config = function()
      require("gitlab").setup()
    end,
  },
}
