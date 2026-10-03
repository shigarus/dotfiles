local function findBufferID()
  for _, v in pairs(vim.api.nvim_list_bufs()) do
    local bufname = vim.api.nvim_buf_get_name(v)
    -- /bin/sh means some plugin opened terminal window for its work (for example fzf-lua)
    if vim.startswith(bufname, 'term://') and not vim.endswith(bufname, '/bin/sh') then
      return v
    end
  end
  return nil
end

local function ToggleTerminal()
  if vim.bo.buftype == 'terminal' then
    vim.cmd 'bp'
    return
  end

  local termBufID = findBufferID()

  if termBufID then
    vim.cmd('b' .. termBufID)
  else
    vim.cmd 'term'
  end
end

return function()
  -- these are the same keybind
  vim.keymap.set({ 'n', 'v', 's', 'o', 't' }, '†', ToggleTerminal)
  vim.keymap.set({ 'n', 'v', 's', 'o', 't' }, '<A-t>', ToggleTerminal)
  vim.keymap.set({ 'n', 'v', 's', 'o', 't' }, '∫', function()
    require('fzf-lua').buffers()
  end)
  vim.keymap.set({ 'n', 'v', 's', 'o', 't' }, '<A-b>', function()
    require('fzf-lua').buffers()
  end)

  vim.keymap.set({ 't' }, '<ESC>', '<C-\\><C-n>')
  vim.keymap.set({ 't' }, '<C-ESC>', '<ESC>')
end
