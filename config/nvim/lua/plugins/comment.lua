return {
  "numToStr/Comment.nvim",
  event = "VeryLazy",
  config = function()
    require("Comment").setup()

    local api = require("Comment.api")

    -- VS-style mappings
    vim.keymap.set("n", "<C-k><C-c>", function()
      api.toggle.linewise.current()
    end, { desc = "Comment line" })

    vim.keymap.set("v", "<C-k><C-c>", function()
      api.toggle.linewise(vim.fn.visualmode())
    end, { desc = "Comment selection" })

    vim.keymap.set("n", "<C-k><C-u>", function()
      api.uncomment.linewise.current()
    end, { desc = "Uncomment line" })

    vim.keymap.set("v", "<C-k><C-u>", function()
      api.uncomment.linewise(vim.fn.visualmode())
    end, { desc = "Uncomment selection" })

    -- Recommended ergonomic mapping
    vim.keymap.set("n", "<leader>/", api.toggle.linewise.current, { desc = "Toggle comment" })
    vim.keymap.set("v", "<leader>/", function()
      api.toggle.linewise(vim.fn.visualmode())
    end, { desc = "Toggle comment (visual)" })
  end,
}
