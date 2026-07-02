return {
    {
        "stevearc/conform.nvim",
        opts = {
            formatters_by_ft = {},
        },
    },
    {
        "williamboman/mason.nvim",
        cmd = "Mason",
        opts = {},
    },
    {
        "williamboman/mason-lspconfig.nvim",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = { "williamboman/mason.nvim" },
    },
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/nvim-cmp",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
            "j-hui/fidget.nvim",
        },
        config = function()
            local has_go = vim.fn.executable("go") == 1

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

            if has_go then
                formatters.go = { "goimports", "gofmt" }
            end

            require("conform").setup({
                formatters_by_ft = formatters,
            })

            local cmp = require("cmp")
            local cmp_lsp = require("cmp_nvim_lsp")
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities = vim.tbl_deep_extend("force", capabilities, cmp_lsp.default_capabilities())
            vim.lsp.config("*", {
                capabilities = capabilities,
            })

            require("fidget").setup({})
            require("mason").setup()

            local ok_mason_lsp, mason_lspconfig = pcall(require, "mason-lspconfig")
            
            -- Intercept notifications to silence the OmniSharp 'nil' bug
            local original_notify = vim.notify
            vim.notify = function(msg, level, opts)
                if msg and msg:find("INVALID_SERVER_MESSAGE: nil") then
                    return -- Do nothing, silently drop this error
                end
                original_notify(msg, level, opts)
            end

            local servers = {
                "lua_ls",
                "vtsls",
                "tailwindcss",
                "pyright",
                "jsonls",
                "omnisharp",
                "clangd",
            }

            if has_go then
                table.insert(servers, "gopls")
            end

            if ok_mason_lsp then
                mason_lspconfig.setup({
                    ensure_installed = servers,
                    automatic_enable = false,
                })
            end

            local function setup_server(server, opts)
                opts = opts or {}
                opts.capabilities = vim.tbl_deep_extend("force", capabilities, opts.capabilities or {})

                local ok_config = pcall(vim.lsp.config, server, opts)
                if not ok_config then
                    vim.notify("LSP config not found for: " .. server, vim.log.levels.WARN)
                    return
                end

                local ok_enable = pcall(vim.lsp.enable, server)
                if not ok_enable then
                    vim.notify("Failed to enable LSP server: " .. server, vim.log.levels.WARN)
                end
            end

            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local opts = { buffer = args.buf, remap = false }
                    if vim.lsp.inlay_hint then
                        vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
                    end
                    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
                    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
                    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                    vim.keymap.set("n", "gws", function()
                        vim.ui.input({ prompt = "Workspace Symbol > " }, function(query)
                            if query and query ~= "" then
                                vim.lsp.buf.workspace_symbol(query)
                            end
                        end)
                    end, opts)
                    vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
                    vim.keymap.set("n", "gE", vim.diagnostic.goto_prev, opts)
                    vim.keymap.set("n", "ge", vim.diagnostic.goto_next, opts)
                    vim.keymap.set("n", "ga", vim.lsp.buf.code_action, opts)
                    vim.keymap.set("n", "gu", vim.lsp.buf.references, opts)
                    vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, opts)
                    vim.keymap.set("n", "<leader>f", function()
                        require("conform").format({ async = true, lsp_fallback = true })
                    end, opts)
                    vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
                    vim.keymap.set("n", "<leader>oi", function()
                        vim.lsp.buf.code_action({ apply = true, context = { only = { "source.organizeImports" } }, })
                    end, opts)
                end,
            })

            setup_server("lua_ls", {
                capabilities = capabilities,
                settings = {
                    Lua = {
                        runtime = { version = "LuaJIT" },
                        diagnostics = { globals = { "vim" } },
                        workspace = {
                            library = vim.api.nvim_get_runtime_file("", true),
                            checkThirdParty = false,
                        },
                        format = {
                            enable = true,
                            defaultConfig = {
                                indent_style = "space",
                                indent_size = "2",
                            },
                        },
                        completion = {
                            callSnippet = "Replace",
                        },
                        telemetry = { enable = false },
                    },
                },
            })

            setup_server("tailwindcss", {
                capabilities = capabilities,
                filetypes = {
                    "html",
                    "css",
                    "scss",
                    "javascript",
                    "javascriptreact",
                    "typescript",
                    "typescriptreact",
                    "vue",
                    "svelte",
                    "heex",
                },
            })

            setup_server("vtsls", {
                capabilities = capabilities,
                settings = {
                    typescript = {
                        inlayHints = {
                            parameterNames = { enabled = "all" },
                            parameterTypes = { enabled = true },
                            variableTypes = { enabled = true },
                            propertyDeclarationTypes = { enabled = true },
                            functionLikeReturnTypes = { enabled = true },
                        },
                    },
                },
            })
            setup_server("pyright", {
                filetypes = { "python" },
                capabilities = capabilities,
                settings = {
                    python = {
                        analysis = {
                            typeCheckingMode = "basic", -- or "strict"
                            autoSearchPaths = true,
                            useLibraryCodeForTypes = true,
                        },
                    },
                },
            })
            setup_server("jsonls", {
                capabilities = capabilities,
                settings = {
                    json = {
                        validate = { enable = true },
                    },
                },
            })
            setup_server("omnisharp", {
                filetypes = { "cs" },
                capabilities = capabilities,
                enable_import_completion = true,
                organize_imports_on_format = true,
                enable_roslyn_analyzers = true,
            })
            if has_go then
                setup_server("gopls", {
                    capabilities = capabilities,
                    filetypes = { "go", "gomod", "gowork", "gotmpl" },
                    settings = {
                        gopls = {
                            analyses = {
                                unusedparams = true,
                                shadow = true,
                            },
                            staticcheck = true,
                        },
                    },
                })
            end
            setup_server("clangd", {
                capabilities = capabilities,
            })

            local cmp_select = { behavior = cmp.SelectBehavior.Select }
            cmp.setup({
                snippet = {
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
                    ["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                    ["<C-Space>"] = cmp.mapping.complete(),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                }, {
                    { name = "buffer" },
                }),
            })

            vim.diagnostic.config({
                float = {
                    focusable = false,
                    style = "minimal",
                    border = "rounded",
                    source = "always",
                    header = "",
                    prefix = "",
                },
            })
        end,
    },
}
