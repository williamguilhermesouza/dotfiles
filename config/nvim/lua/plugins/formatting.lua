return {
    {
        "stevearc/conform.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = function()
            local formatters = {
                lua = { "stylua" },
                javascript = { "prettier" },
                typescript = { "prettier" },
                javascriptreact = { "prettier" },
                typescriptreact = { "prettier" },
                json = { "prettier" },
                css = { "prettier" },
                html = { "prettier" },
                python = { "black" },
                cs = { "csharpier" },
                c = { "clang-format" },
                cpp = { "clang-format" },
            }

            if vim.fn.executable("go") == 1 then
                formatters.go = { "goimports", "gofmt" }
            end

            return {
                formatters_by_ft = formatters,
            }
        end,
    },
}
