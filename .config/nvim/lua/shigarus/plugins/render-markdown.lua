return {
  'MeanderingProgrammer/render-markdown.nvim',
  dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
  -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
  -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {
    code = { style = 'language' },
    completions = { blink = { enabled = true } },
  },
  event = { 'BufEnter *.md' },
  config = function(_, opts)
    require('render-markdown').setup(opts)
    vim.cmd 'highlight RenderMarkdownCode guibg=#2C2A2E guifg=#7AD9E5'
    vim.cmd 'highlight @markup.raw.block.markdown guibg=#2C2A2E'
  end,
}
