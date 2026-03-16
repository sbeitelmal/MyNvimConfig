-- return { 'catppuccin/nvim', name = 'catppuccin', priority = 1000, vim.cmd.colorscheme 'catppuccin-nvim' }
return {
  require('catppuccin').setup {
    flavour = 'mocha',
    transparent_background = false, -- disables setting the background color.
  },
}
