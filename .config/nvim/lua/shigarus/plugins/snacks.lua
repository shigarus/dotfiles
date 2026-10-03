return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    git = { enabled = true },
    gitbrowse = {
      config = function(opts, defaults)
        opts.url_patterns['gitlab.nebius.dev'] = {
          branch = '/-/tree/{branch}',
          file = '/-/blob/{branch}/{file}#L{line_start}-L{line_end}',
          permalink = '/-/blob/{commit}/{file}#L{line_start}-L{line_end}',
          commit = '/-/commit/{commit}',
        }
      end,
      enabled = true,
    },
    indent = { enabled = true },
    input = { enabled = true },
    -- conflicts with noice
    notifier = {
      enabled = vim.env.IS_NOTES == nil,
      filter = function(notif)
        -- local to_filter = { 'lines' }
        local to_filter = {}
        for _, l in pairs(to_filter) do
          if notif.msg:find(l) then
            return false
          end
        end
        return true
        -- that is old filter
        --       find = 'written',
        --       find = 'before #',
        --       find = 'match',
        --       find = 'after #',
        --       find = 'lines',
        --       find = 'Already at newest change',
      end,
    },
    quickfile = { enabled = true },
    -- scope = { enabled = true },
    scroll = { enabled = true },
    words = { enabled = true },
  },
  keys = {
    {
      '<leader>gb',
      function()
        Snacks.gitbrowse()
      end,
      desc = 'Git Browse',
      mode = { 'n', 'v' },
    },
    {
      '<leader>gy',
      function()
        Snacks.gitbrowse {
          open = function(url)
            vim.fn.setreg('+', url)
          end,
          notify = false,
        }
      end,
      desc = 'Git Browse (copy)',
    },
    -- {
    --   '<leader>gg',
    --   function()
    --     Snacks.lazygit()
    --   end,
    --   desc = 'Lazygit',
    -- },
  },
}
