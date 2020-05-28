" Import of vim Plug plugins list file
source ~/.config/nvim/plugins.vim
" Import coc.nvim config
source ~/.config/nvim/coc.vim

" turns on vim default syntax highlight,
" overriding other highlights configs
syntax on
set encoding=UTF-8
" enable hidding of edited but not saved files
set hidden
" enable line numbers
set number
" enable relative numbering of lines
" set relativenumber
" autocomplete of commands inside vim
set inccommand=split
"enable mouse support
set mouse=a
" line highlight
set cursorline
" enabling insertion tabs on the start of a line according to shiftwidth, not
" tabstop
set smarttab
" enabling automatically inserts one extra level of indentation in some cases
set smartindent
" dracula theme colorscheme setting
colorscheme dracula
" set the leader key to space
let mapleader="\<space>"
" use leader + ; to put ; at the end of the line
nnoremap <leader>; A;<esc>
" use leader + ev to open init file in vsplit
nnoremap <leader>zv :vsplit ~/.config/nvim/init.vim<cr>
" use leader + sv to save init file 
nnoremap <leader>sv :source ~/config/nvim/init.vim<cr>
" use leader + e to open coc-explorer split
nnoremap <leader>e :CocCommand explorer<cr>

