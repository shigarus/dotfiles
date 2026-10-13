return function()
  -- VIBECODE:
  -- Closing the last terminal shell (for example with Ctrl-D) closes Neovim too.
  local terminal_exit_group = vim.api.nvim_create_augroup('shigarus-terminal-exit', { clear = true })
  local last_deleted_terminals = {}

  -- Neovim 0.12 can delete a successful shell terminal before our TermClose runs.
  -- Remember whether it was the only listed buffer before that deletion.
  vim.api.nvim_create_autocmd('BufDelete', {
    group = terminal_exit_group,
    callback = function(event)
      if vim.v.exiting ~= vim.NIL or vim.bo[event.buf].buftype ~= 'terminal' or not vim.bo[event.buf].buflisted then
        return
      end
      local candidate = {}
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if buf ~= event.buf then
          if vim.bo[buf].modified then
            return
          end
          if vim.bo[buf].buflisted then
            -- Neovim may already have allocated its empty replacement buffer.
            if
              candidate.replacement
              or vim.api.nvim_buf_is_loaded(buf)
              or vim.api.nvim_buf_get_name(buf) ~= ''
              or vim.bo[buf].buftype ~= ''
              or vim.api.nvim_buf_get_changedtick(buf) ~= 1
            then
              return
            end
            candidate.replacement = buf
          end
        end
      end
      last_deleted_terminals[event.buf] = candidate
    end,
  })

  vim.api.nvim_create_autocmd('TermClose', {
    desc = 'Quit when the only listed buffer is a closed terminal',
    group = terminal_exit_group,
    callback = function(event)
      local was_last_deleted = last_deleted_terminals[event.buf]
      last_deleted_terminals[event.buf] = nil
      if vim.v.exiting ~= vim.NIL then
        return
      end
      -- Plugin terminals such as fzf are usually unlisted and must not quit Neovim.
      if not was_last_deleted and (not vim.api.nvim_buf_is_valid(event.buf) or not vim.bo[event.buf].buflisted) then
        return
      end
      -- Let other terminal cleanup callbacks finish before checking buffers.
      vim.schedule(function()
        if vim.v.exiting ~= vim.NIL then
          return
        end
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if buf ~= event.buf and vim.bo[buf].modified then
            return
          end
          if buf ~= event.buf and vim.bo[buf].buflisted then
            -- Deleting the last buffer creates an empty replacement. Only ignore
            -- it when the terminal was already the sole buffer before deletion.
            local empty_replacement = was_last_deleted
              and was_last_deleted.replacement == buf
              and vim.bo[buf].buftype == ''
              and vim.api.nvim_buf_get_name(buf) == ''
              and vim.api.nvim_buf_line_count(buf) == 1
              and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == ''
            if not empty_replacement then
              return
            end
          end
        end
        -- Never force quitting: Neovim must still protect any unsaved changes.
        vim.cmd 'quitall'
      end)
    end,
  })
end
