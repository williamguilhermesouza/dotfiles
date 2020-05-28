source ~/.config/nvim/plugins.vim

syntax on
set encoding=UTF-8
set cursorline
set number
set hidden
set mouse=a
set smarttab
set smartindent
colorscheme dracula

" NERDTree config
map <C-a> :NERDTreeToggle<CR>
let NERDTreeShowHidden=1
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
let NERDTreeMinimalUI=1

" NERDTree highlight active buffer file
function! IsNERDTreeOpen()        
	return exists("t:NERDTreeBufName") && (bufwinnr(t:NERDTreeBufName) != -1)
endfunction
function! SyncTree()
	if &modifiable && IsNERDTreeOpen() && strlen(expand('%')) > 0 && !&diff
		NERDTreeFind
	wincmd p
	endif
endfunction
autocmd BufEnter * call SyncTree()

" Import coc.nvim config
source ~/.config/nvim/coc.vim
