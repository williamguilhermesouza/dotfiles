return {
	{
		'rmagatti/auto-session',
		lazy = false,
		-- keys = {
		-- 	{ '<leader>ss', function() require("auto-session.session-lens").search_session() end, { desc = "Search Session" } },
		-- },
		-- cmd = "SessionRestore",
		config = function()
			require('auto-session').setup({
				log_level = 'error',
				auto_restore_enabled = true,
				-- Close terminal buffers before session save to prevent freeze on exit.
				-- Terminal processes (pwsh, lazygit, opencode, etc.) can block session
				-- serialization and cause Neovim to hang.
				pre_save_cmds = {
					function()
						-- Close all toggleterm terminals
						pcall(function()
							require('toggleterm.terminal').get_all()
							vim.cmd('ToggleTermToggleAll')
						end)
						-- Force-delete any remaining terminal buffers
						for _, buf in ipairs(vim.api.nvim_list_bufs()) do
							if vim.bo[buf].buftype == 'terminal' then
								pcall(vim.api.nvim_buf_delete, buf, { force = true })
							end
						end
					end,
				},
                -- manually triggering events after session load
				post_restore_cmds = {
					function()
						vim.defer_fn(function()
							for _, buf in ipairs(vim.api.nvim_list_bufs()) do
								if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == '' then
									local name = vim.api.nvim_buf_get_name(buf)
									if name ~= '' and vim.fn.filereadable(name) == 1 then
										if vim.bo[buf].filetype == '' then
											local detected = vim.filetype.match({ buf = buf, filename = name })
											if detected then
												vim.bo[buf].filetype = detected
											end
										end

										pcall(vim.api.nvim_exec_autocmds, 'BufReadPost', { buffer = buf, modeline = false })
										pcall(vim.api.nvim_exec_autocmds, 'FileType', { buffer = buf, modeline = false })
										pcall(vim.api.nvim_exec_autocmds, 'BufWinEnter', { buffer = buf, modeline = false })
										pcall(vim.treesitter.start, buf)
									end
								end
							end
						end, 50)
					end,
				},
			})
			-- vim.keymap.set('n', '<leader>ss', function() require("auto-session.session-lens").search_session() end, { desc = "Search Session" })
			vim.keymap.set('n', '<leader>ss', "<cmd>AutoSession search<CR>", { desc = "Search Session" })
		end
	}
}
