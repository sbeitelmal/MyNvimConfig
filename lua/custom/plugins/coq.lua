-- coq_nvim - Fast completion engine
-- Replaces nvim-cmp with coq_nvim for autocompletion.
--
-- coq_nvim is language-agnostic: it pulls completions from whatever LSP
-- server is attached (Roslyn for C#, lua_ls for Lua, etc.).
-- The coq.artifacts plugin ships 9000+ built-in snippets including C#.
--
-- IMPORTANT: coq_nvim and nvim-cmp are mutually exclusive.
-- This file disables nvim-cmp and its ecosystem.

return {
  -- ── Disable nvim-cmp ecosystem ────────────────────────────────────────
  { 'hrsh7th/nvim-cmp', enabled = false },
  { 'hrsh7th/cmp-nvim-lsp', enabled = false },
  { 'hrsh7th/cmp-path', enabled = false },
  { 'saadparwaiz1/cmp_luasnip', enabled = false },
  { 'L3MON4D3/LuaSnip', enabled = false },

  -- ── coq_nvim ──────────────────────────────────────────────────────────
  {
    'ms-jpq/coq_nvim',
    branch = 'coq',
    lazy = false, -- must load at startup
    dependencies = {
      { 'ms-jpq/coq.artifacts', branch = 'artifacts' },
      { 'ms-jpq/coq.thirdparty', branch = '3p' },
    },
    init = function()
      -- coq_settings MUST be set before require("coq") is called
      vim.g.coq_settings = {
        auto_start = 'shut-up',

        keymap = {
          eval_snips = '<leader>j',
        },

        -- Roslyn (C# LSP) can be slow on large Unity projects.
        -- Bumping timeouts gives it more breathing room.
        limits = {
          completion_auto_timeout = 0.2, -- default ~0.088s
          completion_manual_timeout = 1.0, -- default 0.66s
        },

        display = {
          ghost_text = { enabled = true },
          icons = { mode = 'long' },
          preview = {
            positions = { north = 1, south = 2, west = 3, east = 4 },
          },
        },

        clients = {
          lsp = {
            enabled = true,
            -- Higher resolve timeout helps Roslyn finish auto-import edits
            resolve_timeout = 0.5,
          },
          tree_sitter = { enabled = true },
          buffers = { enabled = true },
          paths = { enabled = true },
          snippets = { enabled = true },
          tags = { enabled = false },
          tmux = { enabled = false },
        },

        match = {
          max_results = 33,
        },
      }
    end,

    config = function()
      -- Third-party sources
      require('coq_3p') {
        { src = 'nvimlua', short_name = 'nLUA' },
        { src = 'bc', short_name = 'MATH', precision = 6 },
      }
    end,
  },

}
