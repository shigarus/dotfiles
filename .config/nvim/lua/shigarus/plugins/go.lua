return {
  'ray-x/go.nvim',
  dependencies = { -- optional packages
    'ray-x/guihua.lua',
    'neovim/nvim-lspconfig',
    'nvim-treesitter/nvim-treesitter',
  },
  enabled = vim.env.IS_NOTES ~= 'true',
  config = function()
    local format_sync_grp = vim.api.nvim_create_augroup('GoFormat', {})
    vim.api.nvim_create_autocmd('BufWritePre', {
      pattern = '*.go',
      callback = function()
        require('go.format').gofmt()
      end,
      group = format_sync_grp,
    })
    require('go').setup {
      lsp_cfg = false,
      -- this is probably not working bs, as I run this function as autocommand in lsp config
      lsp_keymaps = require 'shigarus.keymaps.lsp_attach',
      diagnostic = {
        hdlr = false,
        underline = true,
        virtual_text = false,
        update_in_insert = false,
        signs = true,
      },
      lsp_inlay_hints = {
        enable = false,
      },
    }
    local cfg = require('go.lsp').config()
    cfg.cmd = { vim.fn.expand '~/go/bin/gopls' }
    cfg.settings.gopls.usePlaceholders = false
    -- bazel support >_<
    -- cfg.settings.gopls.workspaceFiles = {
    --   '**/BUILD',
    --   '**/WORKSPACE',
    --   '**/*.{bzl,bazel}',
    -- }
    --
    cfg.settings.gopls.env = {
      GO111MODULE = 'on',
      GOPACKAGESDRIVER = '',
    }
    -- cfg.settings.gopls.directoryFilters = {
    --   '-bazel-bin',
    --   '-bazel-out',
    --   '-bazel-testlogs',
    --   '-bazel-mypkg',
    -- }

    vim.lsp.config('gopls', cfg)
    vim.lsp.enable 'gopls'
  end,
  ft = { 'go', 'gomod' },
  build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
}
