return {
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
            "j-hui/fidget.nvim",
        },
        config = function()
            local has_go = vim.fn.executable("go") == 1

            local cmp_lsp = require("cmp_nvim_lsp")
            local capabilities = cmp_lsp.default_capabilities()

            require("fidget").setup({})
            require("mason").setup()

            local ok_mason_lsp, mason_lspconfig = pcall(require, "mason-lspconfig")

            local inlay_hint_servers = {
                gopls = true,
                lua_ls = true,
                vtsls = true,
            }

            local lsp_attach = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true })
            vim.api.nvim_create_autocmd("LspAttach", {
                group = lsp_attach,
                callback = function(args)
                    local function map(mode, lhs, rhs, desc)
                        vim.keymap.set(mode, lhs, rhs, { buffer = args.buf, remap = false, desc = desc })
                    end

                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    if client and inlay_hint_servers[client.name] and vim.lsp.inlay_hint then
                        vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
                    end

                    map("n", "gd", vim.lsp.buf.definition, "LSP definition")
                    map("n", "gi", vim.lsp.buf.implementation, "LSP implementation")
                    map("n", "K", vim.lsp.buf.hover, "LSP hover")
                    map("n", "gws", function()
                        vim.ui.input({ prompt = "Workspace Symbol > " }, function(query)
                            if query and query ~= "" then
                                vim.lsp.buf.workspace_symbol(query)
                            end
                        end)
                    end, "LSP workspace symbols")
                    map("n", "<leader>d", vim.diagnostic.open_float, "Diagnostics float")
                    map("n", "gE", vim.diagnostic.goto_prev, "Previous diagnostic")
                    map("n", "ge", vim.diagnostic.goto_next, "Next diagnostic")
                    map("n", "ga", vim.lsp.buf.code_action, "LSP code action")
                    map("n", "gu", vim.lsp.buf.references, "LSP references")
                    map("n", "<leader>r", vim.lsp.buf.rename, "LSP rename")
                    map("n", "<leader>f", function()
                        require("conform").format({ async = true, lsp_fallback = true })
                    end, "Format buffer")
                    map("i", "<C-h>", vim.lsp.buf.signature_help, "Signature help")
                    map("n", "<leader>oi", function()
                        vim.lsp.buf.code_action({ apply = true, context = { only = { "source.organizeImports" } } })
                    end, "Organize imports")
                end,
            })

            local server_configs = {
                clangd = {},
                jsonls = {
                    settings = {
                        json = {
                            validate = { enable = true },
                        },
                    },
                },
                lua_ls = {
                    settings = {
                        Lua = {
                            runtime = { version = "LuaJIT" },
                            diagnostics = { globals = { "vim" } },
                            workspace = {
                                library = vim.api.nvim_get_runtime_file("", true),
                                checkThirdParty = false,
                            },
                            completion = {
                                callSnippet = "Replace",
                            },
                            telemetry = { enable = false },
                        },
                    },
                },
                pyright = {
                    filetypes = { "python" },
                    settings = {
                        python = {
                            analysis = {
                                typeCheckingMode = "basic",
                                autoSearchPaths = true,
                                useLibraryCodeForTypes = true,
                            },
                        },
                    },
                },
                tailwindcss = {
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
                },
                vtsls = {
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
                },
            }

            if has_go then
                server_configs.gopls = {
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
                }
            end

            local servers = vim.tbl_keys(server_configs)
            table.sort(servers)

            if ok_mason_lsp then
                mason_lspconfig.setup({
                    ensure_installed = servers,
                    automatic_enable = false,
                })
            end

            for _, server in ipairs(servers) do
                local opts = vim.tbl_deep_extend("force", {
                    capabilities = capabilities,
                }, server_configs[server])

                local ok_config = pcall(vim.lsp.config, server, opts)
                if not ok_config then
                    vim.notify("LSP config not found for: " .. server, vim.log.levels.WARN)
                else
                    local ok_enable = pcall(vim.lsp.enable, server)
                    if not ok_enable then
                        vim.notify("Failed to enable LSP server: " .. server, vim.log.levels.WARN)
                    end
                end
            end

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
