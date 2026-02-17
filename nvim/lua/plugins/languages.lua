return {
  {
    "w0rp/ale",
    event = { "BufReadPre", "BufNewFile" },
    init = function()
      vim.g.ale_disable_lsp = 1
    end,
  },
  { "pangloss/vim-javascript", ft = { "javascript", "javascriptreact" } },
  { "leafgarland/typescript-vim", ft = { "typescript", "typescriptreact" } },
  { "jparise/vim-graphql", ft = { "graphql", "javascript", "typescript", "javascriptreact", "typescriptreact" } },
  { "peitalin/vim-jsx-typescript", ft = { "typescriptreact" } },
  { "mattn/emmet-vim", ft = { "html", "css", "javascriptreact", "typescriptreact" } },
}
