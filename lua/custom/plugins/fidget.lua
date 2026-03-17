-- Fidget.nvim + Roslyn progress bridge
-- Bridges roslyn.nvim's custom autocmd events into fidget's progress API
-- so you can see NuGet restore progress AND overall solution loading status.

return {
  'j-hui/fidget.nvim',
  event = 'LspAttach',
  opts = {
    progress = {
      poll_rate = 0,
      suppress_on_insert = false,
      ignore_done_already = false,
      ignore_empty_message = false,
      display = {
        render_limit = 16,
        done_ttl = 3,
        done_icon = '✔',
        done_style = 'Constant',
        progress_ttl = math.huge,
        progress_icon = { pattern = 'dots', period = 1 },
        progress_style = 'WarningMsg',
        group_style = 'Title',
        icon_style = 'Question',
        priority = 30,
        skip_history = true,
      },
    },
    notification = {
      poll_rate = 10,
      override_vim_notify = false,
      window = {
        winblend = 0,
        border = 'none',
        zindex = 45,
        max_width = 0,
        max_height = 0,
        x_padding = 1,
        y_padding = 0,
        align = 'bottom',
        relative = 'editor',
      },
    },
  },

  config = function(_, opts)
    local fidget = require 'fidget'
    fidget.setup(opts)

    -- ──────────────────────────────────────────────────────
    -- 1. Track overall Roslyn solution loading
    --    (from LspAttach → RoslynInitialized)
    -- ──────────────────────────────────────────────────────
    local init_handle = nil

    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('roslyn-fidget-init', { clear = true }),
      callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client and client.name == 'roslyn' and init_handle == nil then
          init_handle = require('fidget.progress').handle.create {
            title = 'Initializing',
            message = 'Loading solution…',
            lsp_client = { name = 'roslyn' },
          }
        end
      end,
    })

    vim.api.nvim_create_autocmd('User', {
      group = vim.api.nvim_create_augroup('roslyn-fidget-initialized', { clear = true }),
      pattern = 'RoslynInitialized',
      callback = function()
        if init_handle then
          init_handle.message = 'Solution ready'
          init_handle:finish()
          init_handle = nil
        end
      end,
    })

    -- If the roslyn client dies or detaches before initializing, clean up
    vim.api.nvim_create_autocmd('LspDetach', {
      group = vim.api.nvim_create_augroup('roslyn-fidget-detach', { clear = true }),
      callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client and client.name == 'roslyn' and init_handle then
          init_handle.message = 'Detached'
          init_handle:finish()
          init_handle = nil
        end
      end,
    })

    -- ──────────────────────────────────────────────────────
    -- 2. NuGet restore progress
    --    (from roslyn.nvim wiki, fires per-project)
    -- ──────────────────────────────────────────────────────
    local restore_handles = {}

    vim.api.nvim_create_autocmd('User', {
      group = vim.api.nvim_create_augroup('roslyn-fidget-restore', { clear = true }),
      pattern = 'RoslynRestoreProgress',
      callback = function(ev)
        local token = ev.data.params[1]
        local info = ev.data.params[2]
        local handle = restore_handles[token]

        if handle then
          handle:report {
            title = info.state,
            message = info.message,
          }
        else
          restore_handles[token] = require('fidget.progress').handle.create {
            title = info.state,
            message = info.message,
            lsp_client = { name = 'roslyn' },
          }
        end

        -- Update the init handle message so you can see restore is happening
        if init_handle then
          init_handle.message = 'Restoring: ' .. (info.message or '')
        end
      end,
    })

    vim.api.nvim_create_autocmd('User', {
      group = vim.api.nvim_create_augroup('roslyn-fidget-restore-result', { clear = true }),
      pattern = 'RoslynRestoreResult',
      callback = function(ev)
        local handle = restore_handles[ev.data.token]
        restore_handles[ev.data.token] = nil

        if handle then
          handle.message = ev.data.err and ev.data.err.message or 'Restore completed'
          handle:finish()
        end
      end,
    })
  end,
}
