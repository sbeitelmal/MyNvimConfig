return {
  'nvimdev/dashboard-nvim',
  event = 'VimEnter',
  config = function()
    require('dashboard').setup {
      theme = 'doom',
      config = {
        -- week_header = { enable = true },
        header = {
          '',
          [[                 _             _           ]],
          [[  /\  /\__ _ ___| |_ ___/\   /(_)_ __ ___  ]],
          [[ / /_/ / _` / __| __/ _ \ \ / / | '_ ` _ \ ]],
          [[/ __  / (_| \__ \ ||  __/\ V /| | | | | | |]],
          [[\/ /_/ \__,_|___/\__\___| \_/ |_|_| |_| |_|]],
          '',
        },
        center = {
          {
            icon = ' ',
            icon_hl = 'Title',
            desc = 'Find Recent Files           SPC s .',
            -- desc_hl = 'String',
            -- key = '',
            -- keymap = 'SPC s .',
            -- key_hl = 'Number',
            -- key_format = ' %s', -- remove default surrounding `[]`
            -- action = 'lua print(2)',
            -- action = 'require(telescope.builtin).builtin.oldfiles',
          },
          {
            icon = ' ',
            desc = 'Find neovim dotfiles        SPC s n',
            -- key = '',
            -- keymap = 'SPC s n',
            -- key_format = ' %s', -- remove default surrounding `[]`
            -- action = 'lua print(3)',
          },
          {
            icon = ' ',
            desc = [[Open file Browser           \]],
            -- key = '',
            -- keymap = 'SPC s n',
            -- key_format = ' %s', -- remove default surrounding `[]`
            -- action = 'lua print(3)',
          },
        },
      },
      -- config
    }
  end,
  dependencies = { { 'nvim-tree/nvim-web-devicons' } },
}
