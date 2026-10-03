return {
  'ibhagwan/fzf-lua',
  -- optional for icon support
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {
    'hide',
    oldfiles = {
      include_current_session = true,
      cwd_only = true,
      stat_file = true,
    },
    previewers = {
      builtin = {
        syntax_limit_b = 1024 * 100, -- 100KB
      },
    },
    keymap = {
      fzf = {
        ['ctrl-q'] = 'select-all+accept',
      },
    },
    grep = {
      hidden = true,
      follow = true,
      no_ignore = true,
    },
    lsp = {
      includeDeclaration = false,
    },
  },
  keys = {
    {
      '<leader>sf',
      function()
        require('fzf-lua').files { hidden = true, find_command = { 'rg', '--files', '--iglob', '!.git', '!bazel-bin/', '!bazel-nebo/', '--hidden' } }
      end,
      desc = '[S]earch [F]iles',
    },
    {
      '<leader>sg',
      function()
        require('fzf-lua').live_grep_glob {
          cmd = "rg --color=always --smart-case -g '!{.git,node_modules,bazel-bin,bazel-nebo,bazel-out,bazel-testlogs}/' --no-messages -e",
        }
      end,
      desc = '[S]earch [G]rep',
    },
    {
      '<leader>sr',
      function()
        require('fzf-lua').resume()
      end,
      desc = '[S]earch [R]esume',
    },
    {
      '<leader>s.',
      function()
        require('fzf-lua').oldfiles()
      end,
      desc = '[S]earch old files [.]',
    },
    {
      '<leader>/',
      function()
        require('fzf-lua').blines()
      end,
      desc = 'Search current buffer [/]',
    },
    {
      '<leader><leader>',
      function()
        require('fzf-lua').buffers()
      end,
      desc = 'Search open buffers [ ]',
    },
    {
      '<leader>sd',
      function()
        require('fzf-lua').diagnostics_document()
      end,
      desc = '[S]earch [D]iagnostics in the document',
    },
    {
      '<leader>ss',
      function()
        require('fzf-lua').lsp_document_symbols()
      end,
      desc = '[S]earch lsp document [S]ymbols',
    },
    {
      '<leader>sw',
      function()
        require('fzf-lua').grep_cword()
      end,
      desc = '[S]earch [w]ord',
    },
    {
      '<leader>sW',
      function()
        require('fzf-lua').grep_cWORD()
      end,
      desc = '[S]earch [W]ORD',
    },
    {
      '<leader>sc',
      function()
        require('fzf-lua').files { cwd = '~/.config' }
      end,
      desc = '[S]earch [C]onfig files',
    },
    {
      '<leader>sk',
      function()
        require('fzf-lua').keymaps()
      end,
      desc = '[S]earch [K]eymaps',
    },
    {
      '<leader>sh',
      function()
        require('fzf-lua').helptags()
      end,
      desc = '[S]earch [H]elp',
    },
    {
      '<leader>su',
      function()
        require('fzf-lua').builtin()
      end,
      desc = '[S]earch [U]niversal',
    },
  },
}
