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
set tabstop=4       " The width of a TAB is set to 4.
                    " Still it is a \t. It is just that
                    " Vim will interpret it to be having
                    " a width of 4.
set shiftwidth=4    " Indents will have a width of 4.
set softtabstop=4   " Sets the number of columns for a TAB.
set expandtab       " Expand TABs to spaces.

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
" use leader + v to open second file
nnoremap <leader>v :vsplit<cr>
" fzf remmaping for <c-p>
nnoremap <c-p> :Files<cr>
" mapping to use Ag to find all ocurrences of a word in a file, needs
" silversearcher-ag to be installed
nnoremap <c-f> :Ag<space>
" terminal configs
command! -nargs=* T belowright split | resize 5 | terminal <args>
command! -nargs=* VT belowright vsplit | terminal <args>
tnoremap <Esc> <C-\><C-n> 
" terminal config mapping to leader + t
nnoremap <leader>t :T<cr>
