return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.5",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local ok_parsers, ts_parsers = pcall(require, "nvim-treesitter.parsers")
      if ok_parsers and ts_parsers.ft_to_lang == nil and vim.treesitter and vim.treesitter.language then
        if vim.treesitter.language.get_lang then
          ts_parsers.ft_to_lang = vim.treesitter.language.get_lang
        end
      end

      local ok_prev_utils, prev_utils = pcall(require, "telescope.previewers.utils")
      if ok_prev_utils then
        prev_utils.ts_highlighter = function()
          return false
        end
      end

      require("telescope").setup({
        defaults = {
          preview = {
            treesitter = false,
          },
        },
      })
    end,
    keys = {
      {
        "<leader>pf",
        function()
          require("telescope.builtin").find_files()
        end,
      },
      {
        "<C-p>",
        function()
          local builtin = require("telescope.builtin")
          local ok = pcall(builtin.git_files)
          if not ok then
            builtin.find_files()
          end
        end,
      },
      {
        "<leader>pws",
        function()
          require("telescope.builtin").grep_string({ search = vim.fn.expand("<cword>") })
        end,
      },
      {
        "<leader>pWs",
        function()
          require("telescope.builtin").grep_string({ search = vim.fn.expand("<cWORD>") })
        end,
      },
      {
        "<leader>ps",
        function()
          require("telescope.builtin").grep_string({ search = vim.fn.input("Grep > ") })
        end,
      },
      {
        "<leader>vh",
        function()
          require("telescope.builtin").help_tags()
        end,
      },
    },
  },
}
