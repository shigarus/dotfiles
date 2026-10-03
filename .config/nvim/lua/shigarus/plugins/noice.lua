return {
  'folke/noice.nvim',
  event = 'VeryLazy',
  opts = {
    -- add any options here
  },
  enabled = vim.env.IS_NOTES == nil,
  dependencies = {
    -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
    'MunifTanjim/nui.nvim',
    -- OPTIONAL:
    --   `nvim-notify` is only needed, if you want to use the notification view.
    --   If not available, we use `mini` as the fallback
    -- 'rcarriga/nvim-notify',
  },
  keys = {

    {
      '<leader>nh',
      function()
        require('noice').cmd 'history'
      end,
      desc = '[N]oice [h]istory',
    },
    {
      '<leader>nl',
      function()
        require('noice').cmd 'last'
      end,
      desc = '[N]oice [l]ast',
    },
    {
      '<leader>nd',
      function()
        require('noice').cmd 'dismiss'
      end,
      desc = '[N]oice [d]ismiss',
    },
    {
      '<leader>ne',
      function()
        require('noice').cmd 'errors'
      end,
      desc = '[N]oice [e]rrors',
    },
    {
      '<leader>ns',
      function()
        require('noice').cmd 'stats'
      end,
      desc = '[N]oice [s]tats',
    },
  },
  config = function()
    require('noice').setup {
      lsp = {
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
          -- ['cmp.entry.get_documentation'] = true, -- requires hrsh7th/nvim-cmp
        },
      },
      -- you can enable a preset for easier configuration
      presets = {
        bottom_search = true, -- use a classic bottom cmdline for search
        command_palette = true, -- position the cmdline and popupmenu together
        -- long_message_to_split = true, -- long messages will be sent to a split
        -- lsp_doc_border = false, -- add a border to hover docs and signature help
      },
      notify = { enabled = false },
      -- routes = {
      --   {
      --     filter = {
      --       event = 'msg_show',
      --       kind = '',
      --       find = 'written',
      --     },
      --     opts = { skip = true },
      --   },
      --   {
      --     filter = {
      --       event = 'msg_show',
      --       kind = '',
      --       find = 'before #',
      --     },
      --     opts = { skip = true },
      --   },
      --   {
      --     filter = {
      --       event = 'msg_show',
      --       kind = '',
      --       find = 'match',
      --     },
      --     opts = { skip = true },
      --   },
      --   {
      --     filter = {
      --       event = 'msg_show',
      --       kind = '',
      --       find = 'after #',
      --     },
      --     opts = { skip = true },
      --   },
      --   {
      --     filter = {
      --       event = 'msg_show',
      --       kind = '',
      --       find = 'lines',
      --     },
      --     opts = { skip = true },
      --   },
      --   {
      --     filter = {
      --       event = 'msg_show',
      --       kind = '',
      --       find = 'Already at newest change',
      --     },
      --     opts = { skip = true },
      --   },
      --   {
      --     view = 'split',
      --     filter = { event = 'msg_show', min_height = 20 },
      --   },
      -- },
    }
  end,
}
