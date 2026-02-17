local nvim_config = vim.fn.stdpath("config")

vim.keymap.set("n", "<leader>oc", function()
  vim.cmd("vsplit " .. vim.fn.fnameescape(nvim_config .. "/init.lua"))
end, { noremap = true, silent = true })

vim.keymap.set("n", "<leader>sc", function()
  dofile(nvim_config .. "/init.lua")
end, { noremap = true, silent = true })

vim.keymap.set("n", "<leader>e", ":CocCommand explorer<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-p>", ":GFiles<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>pf", ":Files<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-f>", ":Ag ", { noremap = true })

vim.cmd([[command! -nargs=* T belowright split | resize 5 | terminal <args>]])
vim.cmd([[command! -nargs=* VT belowright vsplit | terminal <args>]])
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { noremap = true, silent = true })
vim.keymap.set("n", "<leader>t", ":T<CR>", { noremap = true, silent = true })
