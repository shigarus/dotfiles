return {
  url = 'https://git.disroot.org/andyg/leap.nvim',
  enabled = true,
  config = function(_, opts)
    local leap = require 'leap'
    for k, v in pairs(opts) do
      leap.opts[k] = v
    end
    leap.opts.safe_labels = {}
    vim.keymap.set('n', 's', '<Plug>(leap-anywhere)')
    vim.keymap.set('x', 's', '<Plug>(leap)')
    vim.keymap.set('o', 's', '<Plug>(leap-forward)')
    vim.keymap.set('o', 'S', '<Plug>(leap-backward)')
  end,
}
