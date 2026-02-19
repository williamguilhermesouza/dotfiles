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
nnoremap <leader>h :split<CR>
nnoremap <leader>q :q<CR>

" Move selected lines
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" Paste without yanking replaced text
xnoremap <leader>p "_dP

" Clipboard helpers
vnoremap <leader>y "+y
nnoremap <leader>Y gg"+yG

" control d and u centering
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz

" search terms in the middle
nnoremap n nzzzv
nnoremap N Nzzzv

" quickfix list nav
nnoremap <C-k> :cnext<CR>zz
nnoremap <C-j> :cprev<CR>zz
nnoremap <leader>k :lnext<CR>zz
nnoremap <leader>j :lprev<CR>zz

" starts a replace under cursor
nnoremap <leader>s :%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>

" make current file executable
nnoremap <silent> <leader>x :!chmod +x %<CR>

" source current file
nnoremap <leader><enter> :source %<CR>
