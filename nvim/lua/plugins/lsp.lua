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
    dependencies = { "williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim" },
    config = function()
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ts_server_name = "ts_ls"

      local ok_mason_lsp, mason_lspconfig = pcall(require, "mason-lspconfig")
      if ok_mason_lsp then
        mason_lspconfig.setup({
          ensure_installed = { "lua_ls", "pyright", "jsonls", "eslint", ts_server_name },
          automatic_enable = false,
        })
      end

      local function lsp_map(mode, lhs, rhs)
        vim.keymap.set(mode, lhs, rhs, { silent = true, noremap = true })
      end

      local function range_format()
        local start_pos = vim.api.nvim_buf_get_mark(0, "<")
        local end_pos = vim.api.nvim_buf_get_mark(0, ">")
        vim.lsp.buf.format({
          async = true,
          range = {
            ["start"] = { start_pos[1], start_pos[2] },
            ["end"] = { end_pos[1], end_pos[2] },
          },
        })
      end

      lsp_map("n", "[g", vim.diagnostic.goto_prev)
      lsp_map("n", "]g", vim.diagnostic.goto_next)
      lsp_map("n", "gd", vim.lsp.buf.definition)
      lsp_map("n", "gy", vim.lsp.buf.type_definition)
      lsp_map("n", "gi", vim.lsp.buf.implementation)
      lsp_map("n", "gr", vim.lsp.buf.references)
      lsp_map("n", "K", vim.lsp.buf.hover)
      lsp_map("n", "<leader>rn", vim.lsp.buf.rename)
      lsp_map("n", "<leader>a", vim.lsp.buf.code_action)
      lsp_map("x", "<leader>a", vim.lsp.buf.code_action)
      lsp_map("n", "<leader>ac", vim.lsp.buf.code_action)
      lsp_map("n", "<leader>qf", function()
        vim.lsp.buf.code_action({ context = { only = { "quickfix" } } })
      end)
      lsp_map("n", "<leader>f", function()
        vim.lsp.buf.format({ async = true })
      end)
      lsp_map("x", "<leader>f", range_format)
      if vim.lsp.buf.selection_range then
        lsp_map("n", "<C-s>", vim.lsp.buf.selection_range)
        lsp_map("x", "<C-s>", vim.lsp.buf.selection_range)
      end

      lsp_map("n", "<space>a", vim.diagnostic.setloclist)
      lsp_map("n", "<space>e", ":Mason<CR>")
      lsp_map("n", "<space>c", vim.lsp.buf.code_action)
      lsp_map("n", "<space>o", vim.lsp.buf.document_symbol)
      lsp_map("n", "<space>s", function()
        vim.ui.input({ prompt = "Workspace symbols: " }, function(query)
          if query and query ~= "" then
            vim.lsp.buf.workspace_symbol(query)
          end
        end)
      end)
      lsp_map("n", "<space>j", vim.diagnostic.goto_next)
      lsp_map("n", "<space>k", vim.diagnostic.goto_prev)
      lsp_map("n", "<space>p", "<cmd>lopen<CR>")

      vim.api.nvim_create_user_command("Format", function()
        vim.lsp.buf.format({ async = true })
      end, {})

      vim.api.nvim_create_user_command("OR", function()
        local params = {
          command = "_typescript.organizeImports",
          arguments = { vim.api.nvim_buf_get_name(0) },
        }
        vim.lsp.buf.execute_command(params)
      end, {})

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client then
            return
          end

          vim.bo[args.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

          if client.server_capabilities.documentHighlightProvider then
            local group = vim.api.nvim_create_augroup("lsp_document_highlight", { clear = false })
            vim.api.nvim_clear_autocmds({ group = group, buffer = args.buf })
            vim.api.nvim_create_autocmd("CursorHold", {
              group = group,
              buffer = args.buf,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd("CursorMoved", {
              group = group,
              buffer = args.buf,
              callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })

      local function setup(server, opts)
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

      setup("lua_ls", {
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
          },
        },
      })
      setup("pyright", { capabilities = capabilities })
      setup("jsonls", { capabilities = capabilities })
      setup("eslint", { capabilities = capabilities })
      setup(ts_server_name, { capabilities = capabilities })
      setup("tsserver", { capabilities = capabilities })
    end,
  },
}
