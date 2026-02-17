local lazy_root = vim.fn.expand("~/.nvim/lazy")
local lazypath = lazy_root .. "/lazy.nvim"
local uv = vim.uv or vim.loop
if not uv.fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    lazyrepo,
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    error("Failed to clone lazy.nvim:\n" .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
  defaults = { lazy = true },
  root = lazy_root,
  checker = { enabled = false },
  change_detection = { notify = false },
})
