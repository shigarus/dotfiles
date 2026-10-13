return {
  'folke/todo-comments.nvim',
  event = 'VimEnter',
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = {
    keywords = {
      VIBECODE = {
        icon = '💩',
        color = '#834333',
      },
    },
  },
}
