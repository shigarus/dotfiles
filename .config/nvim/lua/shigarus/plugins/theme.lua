return {
  --   'catppuccin/nvim',
  --   name = 'catppuccin',
  --   priority = 1000,
  -- }
  --   'polirritmico/monokai-nightasty.nvim',
  --   lazy = false,
  --   priority = 1000,
  --   ---@type monokai.UserConfig
  --   opts = {
  --     dark_style_background = 'default',
  --     light_style_background = 'default',
  --     markdown_header_marks = true,
  --     -- hl_styles = { comments = { italic = false } },
  --     terminal_colors = function(colors)
  --       return { fg = colors.fg_dark }
  --     end,
  --   },
  --   config = function(_, opts)
  --     vim.opt.cursorline = true -- Highlight line at the cursor position
  --     vim.o.background = 'dark' -- Default to dark theme
  --
  --     require('monokai-nightasty').load(opts)
  --   end,
  -- }
  -- 'loctvl842/monokai-pro.nvim',
  -- priority = 1000,
  -- init = function()
  --   vim.cmd.colorscheme 'monokai-pro'
  -- end,
  -- config = function()
  --   require('monokai-pro').setup {
  --     devicons = true,
  --     background_clear = {},
  --   }
  --   vim.cmd 'highlight LeapBackdrop guifg=#777777'
  -- end,
  'neanias/everforest-nvim',
  version = false,
  lazy = false,
  priority = 1000,
  opts = {
    background = 'hard',
    colours_override = function(palette)
      palette.bg0 = '#1f2326'
    end,
  },
  config = function(_, opts)
    local m = require 'everforest'
    m.setup(opts)
    m.load()
  end,
}
