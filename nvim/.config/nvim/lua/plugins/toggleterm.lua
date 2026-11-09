-- ============================================================================
-- Plugin: toggleterm.nvim
-- Purpose: Persist and toggle multiple terminal windows inside Neovim.
--
-- Terminal Management Keymaps:
--   <C-\>             - Toggle default horizontal terminal #1 (Normal, Insert, Terminal modes)
--   <count><C-\>      - Toggle numbered terminal instance (e.g. 2<C-\> opens terminal #2)
--   <leader>Th        - Open/toggle horizontal split terminal
--   <leader>Tv        - Open/toggle vertical split terminal (side-by-side)
--   <leader>Ta        - Toggle ALL open terminal splits at once (:ToggleTermToggleAll)
--   <leader>fl        - Interactive active terminals picker (:Terminals) to select & focus
--   <leader>fb        - Telescope buffers (also lists running terminal sessions)
--   <leader>gg        - Toggle dedicated Lazygit floating window
--
-- Navigation Inside Terminal Windows:
--   jk                - Exit terminal mode into Normal mode (allows cursor scrolling & yanking)
--   <C-h/j/k/l>       - Jump directly to adjacent Neovim window splits without leaving terminal mode
--
-- Lazygit Controls (active inside the floating Lazygit window):
--   h / l             - Switch between sidebar panels and main diff viewer
--   j / k             - Move cursor down / up inside active list (files, commits, branches)
--   1 - 5             - Jump directly to panel (1: Status, 2: Files, 3: Branches, 4: Commits, 5: Stash)
--   [ / ]             - Previous / Next tab panel
--   <Space>           - Stage / unstage selected file or hunk
--   c                 - Open commit dialog
--   P / p             - Push / Pull changes
--   q                 - Quit Lazygit and close floating window
--   ?                 - Open Lazygit's full built-in keybindings cheatsheet
-- ============================================================================

return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		cmd = { "ToggleTerm", "ToggleTermToggleAll", "TermExec", "Terminals" },
		keys = {
			{ [[<c-\>]], desc = "Toggle terminal" },
			{ "<leader>gg", desc = "Open Lazygit" },
			{ "<leader>fl", desc = "Find active terminals" },
			{ "<leader>Th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Horizontal terminal split" },
			{ "<leader>Tv", "<cmd>ToggleTerm direction=vertical<cr>", desc = "Vertical terminal split" },
			{ "<leader>Ta", "<cmd>ToggleTermToggleAll<cr>", desc = "Toggle all terminals" },
		},
		config = function()
			require("toggleterm").setup({
				-- Dynamic split sizing: 15 lines for horizontal, 40% width for vertical
				size = function(term)
					if term.direction == "horizontal" then
						return 15
					elseif term.direction == "vertical" then
						return vim.o.columns * 0.4
					end
				end,
				open_mapping = [[<c-\>]], -- Global toggle shortcut
				hide_numbers = true,
				shade_filetypes = {},
				shade_terminals = false,
				highlights = {
					Normal = { link = "Normal" },
					NormalFloat = { link = "Normal" },
					FloatBorder = { link = "Normal" },
				},
				start_in_insert = true, -- Automatically enter insert mode when focused
				insert_mappings = true, -- Allow open_mapping to toggle while in insert mode
				persist_size = true,
				persist_mode = true, -- Remember whether terminal was in normal or insert mode
				direction = "horizontal", -- Default layout: horizontal bottom split
				auto_scroll = true, -- Scroll to bottom when output arrives
			})

			-- Attach navigation shortcuts only to regular shell terminals.
			-- Exclude Lazygit so Neovim doesn't intercept <C-j> or drop floating window focus.
			local function set_terminal_keymaps(bufnr)
				local buf_name = vim.api.nvim_buf_get_name(bufnr)
				if buf_name:find("lazygit") then
					return
				end

				local opts = { buffer = bufnr }
				vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)
				vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
				vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
				vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
				vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
			end

			vim.api.nvim_create_autocmd("TermOpen", {
				pattern = "term://*toggleterm#*",
				callback = function(args)
					set_terminal_keymaps(args.buf)
				end,
			})

			-- Interactive picker to view and switch between all active terminals
			local Terminal = require("toggleterm.terminal").Terminal
			local terminal_module = require("toggleterm.terminal")

			local function select_active_terminal()
				local terms = terminal_module.get_all(true)
				if #terms == 0 then
					vim.notify("No active terminals running", vim.log.levels.INFO, { title = "ToggleTerm" })
					return
				end

				vim.ui.select(terms, {
					prompt = "Active Terminals:",
					format_item = function(term)
						local label = term.display_name or (term.cmd and term.cmd ~= "" and term.cmd or ("Terminal #" .. term.id))
						local status = term:is_open() and "● open" or "○ hidden"
						local dir = term.direction or "horizontal"
						return string.format("%-16s  %-10s  [%s]", label, status, dir)
					end,
				}, function(choice)
					if choice then
						choice:open()
					end
				end)
			end

			vim.api.nvim_create_user_command("Terminals", select_active_terminal, { desc = "List and select active terminals" })

			-- Dedicated Lazygit floating popup terminal
			local lazygit = Terminal:new({
				cmd = "lazygit",
				hidden = true,
				direction = "float",
				float_opts = { border = "rounded" },
				on_open = function(_)
					vim.cmd("startinsert!")
				end,
			})

			-- Lazygit toggle
			vim.keymap.set("n", "<leader>gg", function()
				lazygit:toggle()
			end, { desc = "Open Lazygit" })

			-- Interactive terminal picker under [F]ind group
			vim.keymap.set("n", "<leader>fl", select_active_terminal, { desc = "Find active terminals" })

			-- Terminal layout splits under [T]erminal group
			vim.keymap.set("n", "<leader>Th", "<cmd>ToggleTerm direction=horizontal<cr>", { desc = "Horizontal terminal split" })
			vim.keymap.set("n", "<leader>Tv", "<cmd>ToggleTerm direction=vertical<cr>", { desc = "Vertical terminal split" })
			vim.keymap.set("n", "<leader>Ta", "<cmd>ToggleTermToggleAll<cr>", { desc = "Toggle all terminals" })
		end,
	},
}
