-- local custom_monokai = require 'lualine.themes.monokai'
-- custom_monokai.normal.c.bg = '#272822'

Tmux_session_name = ''
local function update_tmux_session_name()
  local p = io.popen 'tmux ls'
  if not p then
    return
  end
  local ctr = 0
  local found_name = ''
  for l in p:lines() do
    ctr = ctr + 1
    if l:match '(attached)' then
      found_name = l:match '^([^:]+):'
    end
  end
  p:close()
  if ctr > 1 then
    Tmux_session_name = found_name
  else
    Tmux_session_name = ''
  end
end

local function contiuous_upd()
  update_tmux_session_name()
  vim.defer_fn(contiuous_upd, 1000)
end

vim.defer_fn(contiuous_upd, 0)

local function tmux_windows()
  local function trim(s)
    return (s:gsub('^%s+', ''):gsub('%s+$', ''))
  end

  -- Ensure we are inside tmux
  do
    local p = io.popen "tmux display-message -p '#{session_id}' 2>/dev/null"
    if not p then
      return ''
    end
    local sid = p:read '*a'
    p:close()
    if trim(sid) == '' then
      return ''
    end
  end

  local p = io.popen "tmux list-windows -F '#I #W #{window_active}'"
  if not p then
    return ''
  end

  local parts = {}
  for line in p:lines() do
    local idx, name, active = line:match '^(%S+)%s+(.+)%s+(%d+)$'
    if idx and name and active then
      local item = idx .. ' ' .. name
      if active == '1' then
        item = '❱ ' .. item .. ' ❰'
      end
      table.insert(parts, item)
    end
  end
  p:close()
  if #parts < 2 then
    return ''
  end

  return table.concat(parts, ' ')
end

local oil_lualine_extension = {
  filetypes = { 'oil' },
  sections = {
    lualine_a = {
      function()
        local ok, oil = pcall(require, 'oil')
        if ok then
          return vim.fn.fnamemodify(oil.get_current_dir(), ':~')
        end
        return ''
      end,
    },
    lualine_y = { tmux_windows },
  },
}

return {
  'nvim-lualine/lualine.nvim',
  enabled = vim.env.IS_NOTES == nil,
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local lualine = require 'lualine'
    local colors = {
      bg0 = '#323d43',
      bg1 = '#1f2326',
      bg3 = '#505a60',
      fg = '#d8caac',
      aqua = '#87c095',
      green = '#a7c080',
      orange = '#e39b7b',
      purple = '#d39bb6',
      red = '#e68183',
      grey1 = '#868d80',
    }

    local theme = {
      normal = {
        a = { bg = colors.green, fg = colors.bg0, gui = 'bold' },
        b = { bg = colors.bg3, fg = colors.fg },
        c = { bg = colors.bg1, fg = colors.fg },
      },
      insert = {
        a = { bg = colors.fg, fg = colors.bg0, gui = 'bold' },
        b = { bg = colors.bg3, fg = colors.fg },
        c = { bg = colors.bg1, fg = colors.fg },
      },
      visual = {
        a = { bg = colors.red, fg = colors.bg0, gui = 'bold' },
        b = { bg = colors.bg3, fg = colors.fg },
        c = { bg = colors.bg1, fg = colors.fg },
      },
      replace = {
        a = { bg = colors.orange, fg = colors.bg0, gui = 'bold' },
        b = { bg = colors.bg3, fg = colors.fg },
        c = { bg = colors.bg1, fg = colors.fg },
      },
      command = {
        a = { bg = colors.aqua, fg = colors.bg0, gui = 'bold' },
        b = { bg = colors.bg3, fg = colors.fg },
        c = { bg = colors.bg1, fg = colors.fg },
      },
      terminal = {
        a = { bg = colors.purple, fg = colors.bg0, gui = 'bold' },
        b = { bg = colors.bg3, fg = colors.fg },
        c = { bg = colors.bg1, fg = colors.fg },
      },
      inactive = {
        a = { bg = colors.bg1, fg = colors.grey1, gui = 'bold' },
        b = { bg = colors.bg1, fg = colors.grey1 },
        c = { bg = colors.bg1, fg = colors.grey1 },
      },
    }
    lualine.setup {
      options = { theme = theme },
      extensions = { 'fzf', oil_lualine_extension, 'quickfix' },
      sections = {
        lualine_a = {
          function()
            return Tmux_session_name
          end,
          'mode',
        },
        lualine_b = { 'branch', 'diff' },
        lualine_c = {
          {
            'filename',
            path = 1,
          },
        },
        lualine_x = { 'diagnostics' },
        lualine_y = { tmux_windows },
      },
    }
  end,
}
