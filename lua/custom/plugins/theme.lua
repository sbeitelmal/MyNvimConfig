return {
  {
    'sainnhe/gruvbox-material',
    lazy = false,
    priority = 1000, -- Load before all other start plugins.
    config = function()
      vim.o.background = 'dark'

      -- Must be set BEFORE loading the colorscheme.
      vim.g.gruvbox_material_background = 'hard' -- hard | medium | soft
      vim.g.gruvbox_material_foreground = 'material' -- material | mix | original
      vim.g.gruvbox_material_enable_italic = true
      vim.g.gruvbox_material_enable_bold = true

      -- Transparency: 1 = bg only, 2 = bg + floating windows
      -- vim.g.gruvbox_material_transparent_background = 0

      -- Better performance with treesitter
      vim.g.gruvbox_material_better_performance = 1

      vim.cmd.colorscheme 'gruvbox-material'
      vim.api.nvim_set_hl(0, 'CursorLine', { bg = '#3c3836' })
    end,
  },
}
