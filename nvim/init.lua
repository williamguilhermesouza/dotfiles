-- Shared config used by nvim/ideavim/vsvim
local shared_vim = vim.fn.expand("~/.vim/init.vim")
local nvim_config = vim.fn.stdpath("config")
if vim.fn.filereadable(shared_vim) == 1 then
  vim.cmd("source " .. vim.fn.fnameescape(shared_vim))
else
  vim.notify("Shared config not found: " .. shared_vim, vim.log.levels.WARN)
end

-- Import vim-plug plugins list and coc.nvim config
local plugins_vim = nvim_config .. "/plugins.vim"
local coc_vim = nvim_config .. "/coc.vim"
if vim.fn.filereadable(plugins_vim) == 1 then
  vim.cmd("source " .. vim.fn.fnameescape(plugins_vim))
else
  vim.notify("Neovim plugins file not found: " .. plugins_vim, vim.log.levels.WARN)
end
if vim.fn.filereadable(coc_vim) == 1 then
  vim.cmd("source " .. vim.fn.fnameescape(coc_vim))
else
  vim.notify("Neovim coc config file not found: " .. coc_vim, vim.log.levels.WARN)
end

-- Neovim-specific settings
vim.cmd([[syntax on]])
vim.opt.encoding = "utf-8"
vim.opt.hidden = true
vim.opt.inccommand = "split"

-- Theme
local ok_colorscheme = pcall(vim.cmd, "colorscheme dracula")
if not ok_colorscheme then
  vim.notify("Colorscheme 'dracula' not found. Using default theme.", vim.log.levels.WARN)
end

-- Open and reload nvim config quickly
vim.keymap.set("n", "<leader>oc", function()
  vim.cmd("vsplit " .. vim.fn.fnameescape(nvim_config .. "/init.lua"))
end, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>sc", function()
  vim.cmd("source " .. vim.fn.fnameescape(nvim_config .. "/init.lua"))
end, { noremap = true, silent = true })

-- Plugin mappings
vim.keymap.set("n", "<leader>e", ":CocCommand explorer<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-p>", ":GFiles<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>pf", ":Files<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-f>", ":Ag ", { noremap = true })

-- Terminal helpers
vim.cmd([[command! -nargs=* T belowright split | resize 5 | terminal <args>]])
vim.cmd([[command! -nargs=* VT belowright vsplit | terminal <args>]])
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { noremap = true, silent = true })
vim.keymap.set("n", "<leader>t", ":T<CR>", { noremap = true, silent = true })
