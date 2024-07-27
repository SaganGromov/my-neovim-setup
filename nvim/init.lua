-- init.lua

-- Load packer.nvim
require('packer').startup(function()
    use 'wbthomason/packer.nvim' -- Package manager
    use 'L3MON4D3/LuaSnip' -- Snippet engine
    use 'hrsh7th/nvim-cmp' -- Autocompletion plugin
    use 'hrsh7th/cmp-nvim-lsp' -- LSP source for nvim-cmp
    use 'hrsh7th/cmp-buffer' -- Buffer source for nvim-cmp
    use 'hrsh7th/cmp-path' -- Path source for nvim-cmp
    use 'hrsh7th/cmp-cmdline' -- Cmdline source for nvim-cmp
    use 'saadparwaiz1/cmp_luasnip' -- Snippet source for nvim-cmp
    use 'neovim/nvim-lspconfig' -- Configurations for Nvim LSP
    use 'ellisonleao/gruvbox.nvim' -- Gruvbox theme
    use 'junegunn/vim-easy-align' -- Easy align
    use 'lervag/vimtex' -- LaTeX support
    use { 'neoclide/coc.nvim', branch = 'release' } -- Coc.nvim
    use 'SirVer/ultisnips' -- Snippets
end)

-- UltiSnips configuration
vim.g.UltiSnipsExpandTrigger = '<tab>'
vim.g.UltiSnipsJumpForwardTrigger = '<tab>'
vim.g.UltiSnipsJumpBackwardTrigger = '<s-tab>'
vim.g.UltiSnipsSnippetDirectories = { "UltiSnips", "my_snippets" }

-- Enable filetype plugins and indentation
vim.cmd 'filetype plugin indent on'

-- Enable syntax highlighting
vim.cmd 'syntax enable'

-- VimTeX viewer configuration
vim.g.vimtex_view_method = 'general'
vim.g.vimtex_view_general_viewer = 'evince'
vim.g.vimtex_view_general_options = '--page-index=@page@ @pdf'

-- General settings
vim.o.number = true
vim.api.nvim_set_keymap('n', '<SPACE>', '/', { noremap = true })

-- Function to insert item on Enter
function InsertItemOnEnter()
    local line = vim.api.nvim_get_current_line()
    if string.match(line, '^%s*\\item') then
        return vim.api.nvim_replace_termcodes("<CR>\\item ", true, true, true)
    else
        return vim.api.nvim_replace_termcodes("<CR>", true, true, true)
    end
end

-- Autocommand group for auto inserting items in LaTeX files only
vim.cmd [[
  augroup auto_insert_item
    autocmd!
    autocmd FileType tex inoremap <buffer> <CR> <C-R>=v:lua.InsertItemOnEnter()<CR>
  augroup END
]]

-- Set shell to zsh
vim.o.shell = '/bin/zsh'

-- DebugVimTeX function
function DebugVimTeX()
    local cmd = 'evince --page-index=' .. vim.fn.line('.') .. ' ' .. vim.fn.expand('%:r') .. '.pdf &'
    print("Executing: " .. cmd)
    vim.fn.system(cmd)
end

-- Autocommand to call DebugVimTeX
vim.cmd 'autocmd User VimtexEventView call v:lua.DebugVimTeX()'

-- Inoremap configurations
vim.api.nvim_set_keymap('i', '"', '""<left>', { noremap = true })
vim.api.nvim_set_keymap('i', "'", "''<left>", { noremap = true })
vim.api.nvim_set_keymap('i', '(', '()<left>', { noremap = true })
vim.api.nvim_set_keymap('i', '[', '[]<left>', { noremap = true })
vim.api.nvim_set_keymap('i', '{', '{}<left>', { noremap = true })
vim.api.nvim_set_keymap('i', '{<CR>', '{<CR>}<ESC>O', { noremap = true })
vim.api.nvim_set_keymap('i', '{;<CR>', '{<CR>};<ESC>O', { noremap = true })

-- VimTeX quickfix configuration
vim.g.vimtex_quickfix_enabled = 0

-- Mapping `,,,` to start VimTeX compilation
vim.api.nvim_set_keymap('n', ',,,', '<Plug>(vimtex-compile)', {})

-- Ensure the Python script is executable
local evinceSyncPath = "/home/sagan/.config/nvim/ftplugin/evinceSync.py"
local handle = io.popen("chmod +x " .. evinceSyncPath)
handle:close()

-- nvim-cmp setup
local has_words_before = function()
    unpack = unpack or table.unpack
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local feedkey = function(key, mode)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

-- Setup nvim-cmp
local cmp = require'cmp'
local luasnip = require'luasnip'

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = {
    ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
    ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    ['<C-e>'] = cmp.mapping({
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    }),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif has_words_before() then
        feedkey("<Tab>", "n")
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'buffer' },
  },
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

-- Setup lspconfig.
local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
require('lspconfig')['texlab'].setup {
  capabilities = capabilities
}

-- Set the colorscheme to gruvbox
vim.o.background = "dark" -- Set to dark mode
vim.cmd([[colorscheme gruvbox]])

-- Remap j and k to move by screen lines
vim.api.nvim_set_keymap('n', 'j', 'gj', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'k', 'gk', { noremap = true, silent = true })

-- Key mapping for forward synchronization
vim.api.nvim_set_keymap('n', '<F4>', ':call SVED_Sync()<CR>', { noremap = true, silent = true })

-- DebugVimTeX function
function DebugVimTeX()
    local cmd = 'evince --page-index=' .. vim.fn.line('.') .. ' ' .. vim.fn.expand('%:r') .. '.pdf &'
    print("Executing: " .. cmd)
    vim.fn.system(cmd)
end

-- Autocommand to call DebugVimTeX
vim.cmd 'autocmd User VimtexEventView call v:lua.DebugVimTeX()'

