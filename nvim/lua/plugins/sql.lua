-- SQL tuning for the `lang.sql` extra.
--
-- The extra defaults sqlfluff to the `ansi` dialect, which flags valid Postgres
-- syntax as errors. Point both the linter and the formatter at `postgres`
-- instead. Change the dialect below if you target a different database.
--
-- Database connections are deliberately NOT set here -- they would be
-- credentials in a config file. Per project, drop a `.lazy.lua` in the repo root
-- (and add it to .gitignore):
--
--   vim.g.dbs = { local_dev = "postgres://user:pass@localhost:5432/dbname" }
--   return {}
--
-- Then `<leader>D` toggles the DB UI.
return {
  -- sqlfluff is installed with Homebrew (`brew install sqlfluff`) instead of
  -- Mason: Mason builds it in its own pip venv, which is slow and was failing
  -- to complete here. Drop it from Mason's list so it doesn't retry forever --
  -- conform and nvim-lint pick up the Homebrew binary from PATH.
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = vim.tbl_filter(function(tool)
        return tool ~= "sqlfluff"
      end, opts.ensure_installed or {})
    end,
  },

  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters = {
        sqlfluff = {
          args = { "format", "--dialect=postgres", "-" },
          -- conform's builtin sets require_cwd = true, so it only runs inside a
          -- directory containing .sqlfluff/pyproject.toml/setup.cfg/tox.ini.
          -- Projects without one silently get no SQL formatting at all. The
          -- dialect is passed on the command line above, so no config file is
          -- needed -- fall back to the file's own
          -- directory instead of refusing to run.
          require_cwd = false,
        },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters = {
        sqlfluff = {
          args = { "lint", "--format=json", "--dialect=postgres" },
        },
      },
    },
  },
}
