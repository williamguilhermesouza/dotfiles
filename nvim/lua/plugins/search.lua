return {
  {
    "junegunn/fzf",
    build = function()
      vim.fn["fzf#install"]()
    end,
    cmd = { "Files", "GFiles", "Ag", "Rg", "Buffers", "History" },
  },
  {
    "junegunn/fzf.vim",
    dependencies = { "junegunn/fzf" },
    cmd = { "Files", "GFiles", "Ag", "Rg", "Buffers", "History" },
  },
}
