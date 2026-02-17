-- Shared config used by nvim/ideavim/vsvim.
local shared_vim = vim.fn.expand("~/.vim/init.vim")
if vim.fn.filereadable(shared_vim) == 1 then
  vim.cmd("source " .. vim.fn.fnameescape(shared_vim))
else
  vim.notify("Shared config not found: " .. shared_vim, vim.log.levels.WARN)
end

require("config.options")
require("config.lazy")
require("config.keymaps")
