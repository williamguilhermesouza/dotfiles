return {
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    build = ":TSUpdate",
    opts = {
      ensure_installed = {
        "vim",
        "vimdoc",
        "lua",
        "javascript",
        "typescript",
        "tsx",
        "graphql",
        "json",
        "python",
        "html",
        "css",
        "bash",
      },
      highlight = { enable = true },
      indent = { enable = true },
    },
    config = function(_, opts)
      local ok_new, ts = pcall(require, "nvim-treesitter")
      if ok_new and ts.setup then
        ts.setup(opts)
        return
      end

      local ok_old, ts_configs = pcall(require, "nvim-treesitter.configs")
      if ok_old then
        ts_configs.setup(opts)
        return
      end

      vim.notify("nvim-treesitter is not available yet. Run :Lazy sync", vim.log.levels.WARN)
    end,
  },
}
