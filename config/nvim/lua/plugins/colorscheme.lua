return {
  {
    "dracula/vim",
    name = "dracula",
    lazy = false,
    priority = 1000,
    config = function()
      local ok = pcall(vim.cmd, "colorscheme dracula")
      if not ok then
        vim.notify("Colorscheme 'dracula' not found. Using default theme.", vim.log.levels.WARN)
      end
    end,
  },
}
