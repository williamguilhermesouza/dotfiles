return {
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G", "Gstatus", "Gcommit", "Gpush", "Gpull", "Gdiffsplit", "Gvdiffsplit" },
    keys = {
      { "<leader>gs", "<cmd>Git<CR>", desc = "Git status" },
    },
    config = function()
      local prime_fugitive = vim.api.nvim_create_augroup("prime_fugitive", {})
      vim.api.nvim_create_autocmd("BufWinEnter", {
        group = prime_fugitive,
        pattern = "*",
        callback = function()
          if vim.bo.ft ~= "fugitive" then
            return
          end

          local bufnr = vim.api.nvim_get_current_buf()
          local opts = { buffer = bufnr, remap = false }
          vim.keymap.set("n", "<leader>gP", function()
            vim.cmd("Git push")
          end, opts, { desc = "Git push" })
          vim.keymap.set("n", "<leader>gp", function()
            vim.cmd("Git pull --rebase")
          end, opts, { desc = "Git pull rebase" })
        end,
      })
    end,
  },
}
