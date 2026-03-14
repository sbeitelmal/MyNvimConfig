-- Roslyn LSP Configuration for Unity
-- Place this file at: ~/.config/nvim/after/lsp/roslyn.lua
--
-- This file is automatically picked up by nvim-lspconfig / vim.lsp.config
-- when the roslyn server is loaded. No need to require it anywhere.

return {
  settings = {
    ['csharp|completion'] = {
      -- Show types from namespaces you haven't imported yet (e.g. UnityEngine.UI)
      dotnet_show_completion_items_from_unimported_namespaces = true,
      dotnet_show_name_completion_suggestions = true,
    },
    ['csharp|inlay_hints'] = {
      csharp_enable_inlay_hints_for_implicit_variable_types = true,
      csharp_enable_inlay_hints_for_implicit_object_creation = true,
      csharp_enable_inlay_hints_for_lambda_parameter_types = true,
    },
    ['csharp|background_analysis'] = {
      -- "openFiles" is lighter on resources, "fullSolution" gives diagnostics everywhere
      -- Start with openFiles; switch to fullSolution if you want project-wide errors
      dotnet_analyzer_diagnostics_scope = 'openFiles',
      dotnet_compiler_diagnostics_scope = 'openFiles',
    },
    ['csharp|code_lens'] = {
      dotnet_enable_references_code_lens = true,
    },
  },
}
