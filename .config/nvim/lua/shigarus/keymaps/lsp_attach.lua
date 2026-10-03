return function(buf)
  local map = function(keys, func, desc, mode)
    mode = mode or 'n'
    vim.keymap.set(mode, keys, func, { buffer = buf, desc = 'LSP: ' .. desc })
  end

  -- Jump to the definition of the word under your cursor.
  --  This is where a variable was first declared, or where a function is defined, etc.
  --  To jump back, press <C-t>.
  map('gd', function()
    require('fzf-lua').lsp_definitions()
  end, '[G]oto [D]efinition')

  -- Find references for the word under your cursor.
  map('gr', function()
    require('fzf-lua').lsp_references()
  end, '[G]oto [R]eferences')

  -- Jump to the implementation of the word under your cursor.
  --  Useful when your language has ways of declaring types without an actual implementation.
  map('gI', function()
    require('fzf-lua').lsp_implementations()
  end, '[G]oto [I]mplementation')

  -- Jump to the type of the word under your cursor.
  --  Useful when you're not sure what type a variable is and you want to see
  --  the definition of its *type*, not where it was *defined*.
  map('<leader>D', function()
    require('fzf-lua').lsp_typedefs()
  end, 'Type [D]efinition')

  map('<C-k>', vim.lsp.buf.signature_help, 'Signature help')

  -- Rename the variable under your cursor.
  --  Most Language Servers support renaming across files, etc.
  map('<leader>rn', function()
    -- if vim.bo.filetype == 'go' then
    --   require('go.rename').lsprename()
    -- else
    vim.lsp.buf.rename()
    -- end
  end, '[R]e[n]ame')

  -- Execute a code action, usually your cursor needs to be on top of an error
  -- or a suggestion from your LSP for this to activate.
  map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })

  -- WARN: This is not Goto Definition, this is Goto Declaration.
  --  For example, in C this would take you to the header.
  map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

  -- The following code creates a keymap to toggle inlay hints in your
  -- code, if the language server you are using supports them
  --
  -- This may be unwanted, since they displace some of your code
  -- if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
  map('<leader>th', function()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
  end, '[T]oggle Inlay [H]ints')
  -- end
end
