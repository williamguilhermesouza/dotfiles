local function get_formatters_by_ft()
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

    return formatters
end

local function get_mason_tools()
    local tools = {
        "stylua",
        "prettier",
        "black",
        "csharpier",
        "clang-format",
    }

    if vim.fn.executable("go") == 1 then
        table.insert(tools, "goimports")
    end

    return tools
end

local warned_missing = {}

local function warn_missing_formatters(bufnr)
    local ok, conform = pcall(require, "conform")
    if not ok then
        return
    end

    local filetype = vim.bo[bufnr].filetype
    if filetype == "" then
        return
    end

    local formatters = get_formatters_by_ft()[filetype] or {}
    for _, formatter in ipairs(formatters) do
        local info = conform.get_formatter_info(formatter, bufnr)
        if not info.available and not warned_missing[formatter] then
            warned_missing[formatter] = true
            vim.schedule(function()
                vim.notify(
                    ("Formatter '%s' is configured for %s but is not available on PATH."):format(formatter, filetype),
                    vim.log.levels.WARN,
                    { title = "Formatting" }
                )
            end)
        end
    end
end

return {
    {
        "stevearc/conform.nvim",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "williamboman/mason.nvim",
            "WhoIsSethDaniel/mason-tool-installer.nvim",
        },
        config = function()
            require("conform").setup({
                formatters_by_ft = get_formatters_by_ft(),
                formatters = {
                    ["clang-format"] = {
                        prepend_args = {
                            "--style={BasedOnStyle: LLVM, BreakBeforeBraces: Allman, UseTab: Always, IndentWidth: 4, TabWidth: 4}",
                        },
                    },
                },
            })

            vim.api.nvim_create_autocmd("BufEnter", {
                group = vim.api.nvim_create_augroup("user_missing_formatter_warning", { clear = true }),
                callback = function(args)
                    warn_missing_formatters(args.buf)
                end,
            })
        end,
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = { "williamboman/mason.nvim" },
        opts = function()
            return {
                ensure_installed = get_mason_tools(),
                run_on_start = true,
                auto_update = false,
                start_delay = 3000,
                debounce_hours = 12,
            }
        end,
    },
}
