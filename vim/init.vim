" Shared Vim config for Neovim, IdeaVim and VsVim.
" Keep only portable options/mappings here.

set number
set relativenumber
set ignorecase
set incsearch
set cursorline
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set smartindent
set scrolloff=8

let mapleader=" "

" Window and quit
nnoremap <leader>v :vsplit<CR>
nnoremap <leader>q :q<CR>

" Move selected lines
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" Paste without yanking replaced text
vnoremap <leader>p "_dP

" Clipboard helpers
vnoremap <leader>y "+y
nnoremap <leader>Y gg"+yG
