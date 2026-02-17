return {
  {
    "neoclide/coc.nvim",
    branch = "release",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "CocInfo", "CocInstall", "CocList", "CocCommand" },
    init = function()
      vim.g.coc_global_extensions = {
        "coc-explorer",
        "coc-git",
        "coc-json",
        "coc-python",
        "coc-tsserver",
        "coc-prettier",
        "coc-eslint",
      }
    end,
    config = function()
      vim.opt.backup = false
      vim.opt.writebackup = false
      vim.opt.cmdheight = 2
      vim.opt.updatetime = 300
      vim.opt.signcolumn = "yes"
      vim.opt.shortmess:append("c")

      vim.cmd([[
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
inoremap <silent><expr> <c-space> coc#refresh()

if exists('*complete_info')
  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif

nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <leader>rn <Plug>(coc-rename)
xmap <leader>f <Plug>(coc-format-selected)
nmap <leader>f <Plug>(coc-format-selected)
xmap <leader>a <Plug>(coc-codeaction-selected)
nmap <leader>a <Plug>(coc-codeaction-selected)
nmap <leader>ac <Plug>(coc-codeaction)
nmap <leader>qf <Plug>(coc-fix-current)
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)
nnoremap <silent> <space>a :<C-u>CocList diagnostics<cr>
nnoremap <silent> <space>e :<C-u>CocList extensions<cr>
nnoremap <silent> <space>c :<C-u>CocList commands<cr>
nnoremap <silent> <space>o :<C-u>CocList outline<cr>
nnoremap <silent> <space>s :<C-u>CocList -I symbols<cr>
nnoremap <silent> <space>j :<C-u>CocNext<CR>
nnoremap <silent> <space>k :<C-u>CocPrev<CR>
nnoremap <silent> <space>p :<C-u>CocListResume<CR>
nnoremap <silent> K :call CocAction('doHover')<CR>
      ]])

      vim.api.nvim_create_autocmd("CursorHold", {
        callback = function()
          if vim.fn.exists("*CocActionAsync") == 1 then
            vim.fn.CocActionAsync("highlight")
          end
        end,
      })

      local coc_group = vim.api.nvim_create_augroup("coc_user_config", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = coc_group,
        pattern = { "typescript", "json" },
        callback = function()
          vim.opt_local.formatexpr = "CocAction('formatSelected')"
        end,
      })
      vim.api.nvim_create_autocmd("User", {
        group = coc_group,
        pattern = "CocJumpPlaceholder",
        callback = function()
          if vim.fn.exists("*CocActionAsync") == 1 then
            vim.fn.CocActionAsync("showSignatureHelp")
          end
        end,
      })

      vim.api.nvim_create_user_command("Format", function()
        vim.fn.CocAction("format")
      end, {})
      vim.api.nvim_create_user_command("Fold", function(opts)
        if opts.args == "" then
          vim.fn.CocAction("fold")
        else
          vim.fn.CocAction("fold", opts.args)
        end
      end, { nargs = "?" })
      vim.api.nvim_create_user_command("OR", function()
        vim.fn.CocAction("runCommand", "editor.action.organizeImport")
      end, {})

      vim.opt.statusline:prepend("%{coc#status()}%{get(b:,'coc_current_function','')}")
    end,
  },
}
