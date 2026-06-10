return {
  "numToStr/Comment.nvim",
  event = "VeryLazy",
  config = function()
    require("Comment").setup()

    local api = require("Comment.api")

    vim.keymap.set("n", "<leader>/", api.toggle.linewise.current, { desc = "Toggle comment" })
    vim.keymap.set("v", "<leader>/", function()
      api.toggle.linewise(vim.fn.visualmode())
    end, { desc = "Toggle comment (visual)" })
  end,
}
