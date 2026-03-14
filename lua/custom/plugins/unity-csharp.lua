-- Unity / C# Development Setup
-- Place this file at: ~/.config/nvim/lua/custom/plugins/unity-csharp.lua
--
-- This configures:
--   1. Mason with the Crashdummyy custom registry (for Roslyn LSP)
--   2. roslyn.nvim plugin (manages the Roslyn C# language server)
--   3. C# treesitter grammar
--   4. LSP settings tuned for Unity development

return {

  -- Override Mason to include the custom registry that provides Roslyn
  {
    'mason-org/mason.nvim',
    opts = {
      registries = {
        'github:mason-org/mason-registry',
        'github:Crashdummyy/mason-registry',
      },
    },
  },

  -- Roslyn.nvim - manages the Roslyn C# language server lifecycle
  -- This replaces the old OmniSharp server with Microsoft's actively developed LSP
  {
    'seblyng/roslyn.nvim',
    ft = 'cs', -- only load when opening a C# file
    dependencies = {
      'mason-org/mason.nvim',
    },
    opts = {
      -- Search parent directories for .sln files
      -- Important for Unity projects where your .sln is at the project root
      -- but you might open nvim from a subfolder
      broad_search = true,
      filewatching = 'roslyn',
    },
  },

  -- Ensure C# treesitter grammar is installed for syntax highlighting
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      -- Append c_sharp to whatever ensure_installed list kickstart already has
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { 'c_sharp' })
    end,
  },
}
