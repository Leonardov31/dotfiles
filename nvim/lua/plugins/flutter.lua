-- Flutter/Dart tooling.
--
-- The `lang.dart` extra starts `dartls` through plain lspconfig. flutter-tools.nvim
-- starts `dartls` itself *and* adds the run/hot-reload/device commands, so letting
-- both run would attach two clients to every Dart buffer. We keep the extra (for
-- treesitter, dart_format and neotest-dart) and hand `dartls` to flutter-tools.
--
-- Commands: :FlutterRun  :FlutterReload  :FlutterRestart  :FlutterDevices
--           :FlutterEmulators  :FlutterDevTools  :FlutterOutlineToggle
--           :FlutterLogToggle  :FlutterQuit

-- Resolve the SDK explicitly so nvim doesn't depend on the PATH it happens to
-- inherit, but stay portable across machines: try the usual install locations,
-- then fall back to whatever is on PATH.
local function flutter_bin()
  local candidates = {
    "~/develop/flutter/bin/flutter",
    "~/flutter/bin/flutter",
    "~/fvm/default/bin/flutter",
    "/opt/homebrew/bin/flutter",
  }
  for _, p in ipairs(candidates) do
    local full = vim.fn.expand(p)
    if vim.fn.executable(full) == 1 then
      return full
    end
  end
  local found = vim.fn.exepath("flutter")
  return found ~= "" and found or nil
end

local bin = flutter_bin()
-- <sdk>/bin/flutter -> <sdk>
local sdk = bin and vim.fn.fnamemodify(bin, ":h:h") or nil

-- Analyzing the SDK's own sources and the pub cache makes dartls slow and fills
-- diagnostics/rename results with code that isn't ours.
local excluded = {}
if sdk then
  excluded = { sdk .. "/.pub-cache", sdk .. "/packages" }
end

return {
  -- stop the lang.dart extra from setting up dartls via lspconfig
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        dartls = { enabled = false },
      },
    },
  },

  {
    "akinsho/flutter-tools.nvim",
    ft = { "dart" },
    cmd = { "FlutterRun", "FlutterDevices", "FlutterEmulators", "FlutterDevTools" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      flutter_path = bin,
      widget_guides = { enabled = true },
      dev_log = {
        enabled = true,
        open_cmd = "botright 15split",
      },
      lsp = {
        color = { enabled = true, background = true },
        settings = {
          showTodos = true,
          completeFunctionCalls = true,
          renameFilesWithClasses = "prompt",
          analysisExcludedFolders = excluded,
        },
      },
    },
  },
}
