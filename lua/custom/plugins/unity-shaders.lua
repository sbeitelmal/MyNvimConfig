-- Unity Shader Development Setup
-- Place this file at: ~/.config/nvim/lua/custom/plugins/unity-shaders.lua
--
-- This configures:
--   1. Filetype detection for Unity shader files (.shader, .cginc, .compute, .hlsl, etc.)
--   2. Treesitter grammars for HLSL and GLSL syntax highlighting
--   3. ShaderHighlight plugin for ShaderLab vim syntax (no treesitter grammar exists)
--   4. Buffer-local settings (indentation, comments) for shader editing
--
-- LSP: glsl_analyzer is added to the `servers` table in init.lua so that
-- mason-tool-installer installs it AND mason-lspconfig auto-configures it.
-- (Extending mason-tool-installer from a custom plugin doesn't work because
-- kickstart's init.lua calls .setup() imperatively, overriding lazy opts.)
--
-- Unity shaders use two languages:
--   - ShaderLab: Unity's DSL for the outer structure (Shader/SubShader/Pass blocks)
--   - HLSL: The actual shader programs inside CGPROGRAM/ENDCG or HLSLPROGRAM/ENDHLSL blocks
--
-- Since there is no tree-sitter parser for ShaderLab, .shader files use the
-- vim regex syntax from ShaderHighlight. Pure .hlsl/.cginc/.compute files get
-- full treesitter-based HLSL highlighting.

-----------------------------------------------------------------------
-- Filetype Detection
-----------------------------------------------------------------------
-- Register Unity shader file extensions with Neovim's filetype system.
-- This runs early so all downstream config (treesitter, LSP, syntax) triggers.
vim.filetype.add {
  extension = {
    -- Unity ShaderLab wrapper files → dedicated filetype for vim regex syntax
    shader = 'shaderlab',

    -- HLSL / Cg includes used inside Unity shaders → treesitter hlsl grammar
    cginc = 'hlsl',
    hlsli = 'hlsl',
    compute = 'hlsl', -- Unity compute shaders are HLSL
    cg = 'hlsl', -- Cg is close enough to HLSL for highlighting

    -- GLSL (less common in Unity but useful for general graphics work)
    glsl = 'glsl',
    vert = 'glsl',
    frag = 'glsl',
    geom = 'glsl',
    tesc = 'glsl',
    tese = 'glsl',
    comp = 'glsl',
  },
}

-----------------------------------------------------------------------
-- Buffer-local settings for shader files
-----------------------------------------------------------------------
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'shaderlab', 'hlsl', 'glsl' },
  group = vim.api.nvim_create_augroup('unity-shader-settings', { clear = true }),
  callback = function()
    -- Unity convention: 4-space indentation for shaders
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
    vim.bo.softtabstop = 4
    vim.bo.expandtab = true

    -- Shader files can have long lines (matrices, long function signatures)
    vim.wo.wrap = false

    -- Comment string for shader files (HLSL/GLSL/ShaderLab all use // style)
    vim.bo.commentstring = '// %s'
  end,
  desc = 'Buffer-local settings for Unity shader files',
})

-----------------------------------------------------------------------
-- Plugin specs
-----------------------------------------------------------------------
return {

  -- ShaderHighlight: vim regex syntax for ShaderLab, HLSL, GLSL, and Cg.
  -- Treesitter will override hlsl/glsl highlighting (it takes priority),
  -- but this plugin is essential for .shader (ShaderLab) files which have NO
  -- treesitter parser. It provides syntax highlighting for the ShaderLab
  -- wrapper language (Shader{}, SubShader{}, Pass{}, Properties{}, Tags{}, etc.)
  {
    'kalvinpearce/ShaderHighlight',
    ft = { 'shaderlab', 'hlsl', 'glsl', 'cg' },
  },

  -- Extend treesitter to install HLSL and GLSL grammars.
  -- These provide proper syntax highlighting for .hlsl, .cginc, .compute, .glsl files.
  -- For .shader files (ShaderLab), the ShaderHighlight vim syntax is used instead
  -- since no treesitter-shaderlab grammar exists.
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { 'hlsl', 'glsl' })
    end,
  },
}
