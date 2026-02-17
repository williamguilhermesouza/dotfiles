" Shared config used by nvim/ideavim/vsvim
source ~/.vim/init.vim

" Import vim-plug plugins list
source ~/.config/nvim/plugins.vim
" Import coc.nvim config
source ~/.config/nvim/coc.vim

" Neovim-specific settings
syntax on
set encoding=UTF-8
set hidden
set inccommand=split

" Theme
colorscheme dracula

" Open and reload nvim config quickly
nnoremap <leader>oc :vsplit ~/.config/nvim/init.vim<CR>
nnoremap <leader>sc :source ~/.config/nvim/init.vim<CR>

" Plugin mappings
nnoremap <leader>e :CocCommand explorer<CR>
nnoremap <C-p> :GFiles<CR>
nnoremap <leader>pf :Files<CR>
nnoremap <C-f> :Ag<Space>

" Terminal helpers
command! -nargs=* T belowright split | resize 5 | terminal <args>
command! -nargs=* VT belowright vsplit | terminal <args>
tnoremap <Esc> <C-\><C-n>
nnoremap <leader>t :T<CR>
