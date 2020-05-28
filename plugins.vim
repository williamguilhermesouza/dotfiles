call plug#begin('~/.config/nvim/plugged')
Plug 'dracula/vim' " dracula color scheme plugin
Plug 'ryanoasis/vim-devicons' " icon themes for nvim
Plug 'terryma/vim-multiple-cursors' " use <c-n> to activate multiple cursors
Plug 'neoclide/coc.nvim', {'branch': 'release'} " coc enable tree navigation and other plugins
Plug 'itchyny/lightline.vim' " configuration for under vim status bar line
Plug 'junegunn/fzf' " fzf terminal program integration to find and navigate between files in vim
Plug 'junegunn/fzf.vim' " config of the fzf
Plug 'mattn/emmet-vim' " emmet for snippets creation
Plug 'tpope/vim-eunuch' " enable some linux commands inside nvim
Plug 'tpope/vim-surround' " activate brackets surround highlight
Plug 'w0rp/ale' " syntax checking on the go
Plug 'tpope/vim-fugitive' " git wrapper for git commands
call plug#end()
