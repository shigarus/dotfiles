return function()
  local map = function(keys, func, desc, mode)
    mode = mode or 'n'
    vim.keymap.set(mode, keys, func, { desc = desc })
  end
  map('<leader>md', function()
    local unchecked = '- %[ %] '
    local checked = '- %[x%] '
    local current_line = vim.api.nvim_get_current_line()
    local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
    local new_line = ''

    if current_line:find(checked) then
      new_line = string.gsub(current_line, checked, unchecked, 1)
    elseif current_line:find(unchecked) then
      new_line = string.gsub(current_line, unchecked, checked, 1)
    else
      Snacks.notify.error 'This is not a checklist item'
      return
    end

    vim.api.nvim_buf_set_lines(0, row - 1, row, true, { new_line })
  end, '[m]arkdown change [d]one status of the checkbox')
  map('<leader>mc', 'o- [ ] ', '[m]arkdown add new [c]heckpoint')
end
