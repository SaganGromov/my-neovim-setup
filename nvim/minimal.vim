call plug#begin('~/config/nvim/plugged')
Plug 'lervag/vimtex'
call plug#end()

filetype plugin indent on
syntax enable

let g:vimtex_view_method = 'general'
let g:vimtex_view_general_viewer = 'evince'
let g:vimtex_view_general_options = '--page-index=@page@tex @pdf'

