-- HTML/CSS language servers.
--
-- LazyVim has no `lang.html` extra, so these are added by hand. Useful for
-- hand-authored static HTML/CSS and for the JSX/CSS side of React projects.
--
-- Listing a server here is enough: LazyVim resolves it through mason-lspconfig
-- and installs the package automatically on next start.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        html = {},
        cssls = {},
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "html", "css", "scss" } },
  },
}
