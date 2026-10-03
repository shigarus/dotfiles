return function()
  local map = function(keys, func, desc, mode)
    mode = mode or 'n'
    vim.keymap.set(mode, keys, func, { desc = desc })
  end
  map('<leader>w', ':w<CR>', '[w]rite current buffer')
  map('<leader>q', ':q<CR>', '[q]uit')
  -- Turn off inline "ghost text"
  vim.diagnostic.config {
    virtual_text = false,
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
  }

  -- Show floating diagnostic when cursor rests on line
  vim.api.nvim_create_autocmd('CursorHold', {
    callback = function()
      vim.diagnostic.open_float(nil, {
        focusable = false,
        close_events = { 'BufLeave', 'CursorMoved', 'InsertEnter', 'FocusLost' },
        border = 'rounded',
        source = 'if_many',
        scope = 'cursor',
      })
    end,
  })

  -- vim.keymap.set('n', '<leader>fb', function()
  --   vim.diagnostic.open_float()
  -- end, { desc = 'Open error as float buffer' })
  -- vim.keymap.set('n', '<leader>fl', function()
  --   local to_set
  --   if type(vim.diagnostic.config().virtual_lines) == 'table' then
  --     to_set = false
  --   else
  --     to_set = { current_line = true }
  --   end
  --   vim.diagnostic.config { virtual_lines = to_set }
  -- end, { desc = 'Toggle tooltips on separate line' })

  function insertFullPath()
    local filepath = vim.fn.expand '%'
    vim.fn.setreg('+', filepath)
  end
  vim.keymap.set('n', '<leader>pc', insertFullPath, { noremap = true, silent = true })
end
