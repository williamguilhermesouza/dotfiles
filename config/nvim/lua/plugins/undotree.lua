return {
  {
    "mbbill/undotree",
    cmd = { "UndotreeToggle", "UndotreeShow" },
    keys = {
      { "<leader>u", "<cmd>UndotreeToggle<CR>" },
    },
    config = function()
      vim.g.undotree_WindowLayout = 2
      if vim.fn.executable("diff") == 0 then
        if vim.fn.executable("git") == 1 then
          vim.g.undotree_DiffCommand = "git diff --no-index --no-color --no-ext-diff"
        else
          vim.g.undotree_DiffAutoOpen = 0
        end
      end
    end,
  },
}
