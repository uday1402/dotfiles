-- ============================================================================
-- Plugin: telescope.nvim
-- Purpose: Highly extensible fuzzy finder over files, buffers, grep, and symbols.
--
-- Layout:
--   Default layout is maximized to 95% screen width and height with a wide (65%)
--   horizontal preview panel on the right side.
--
-- Keymaps (<leader>f group):
--   <leader>ff - Find files in the current working directory
--   <leader>fg - Live grep (search text inside files using ripgrep)
--   <leader>fb - Find and switch between open buffers
--   <leader>fr - Recent files (previously opened files history)
--   <leader>fd - Find diagnostics / errors across the workspace
--   <leader>fs - Document symbols (functions, variables in current file)
--   <leader>fw - Workspace symbols (symbols across all project files)
--   <leader>fh - Help tags (search Neovim :help documentation)
--   <leader>ft - Todo comments (search TODO, FIX, HACK tags across project)
--   <leader>fl - Active terminals (interactive terminal picker)
--
-- Controls (inside any Telescope picker):
--   <C-j> / <Down>  - Move down to next result
--   <C-k> / <Up>    - Move up to previous result
--   <CR>            - Open selected file in current window
--   <C-h>           - Open selected file in a horizontal split
--   <C-v>           - Open selected file in a vertical split
--   <C-t>           - Open selected file in a new tab
--   <C-u> / <C-d>   - Scroll the preview window up / down
--   <C-p>           - Toggle preview window on / off
--   <C-x> / <Esc> / q - Close Telescope
-- ============================================================================

return {
	"nvim-telescope/telescope.nvim",

	branch = "master",
	cmd = "Telescope",

	dependencies = {
		"nvim-lua/plenary.nvim",
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
		},
	},

	keys = {
		{
			"<leader>ff",
			"<cmd>Telescope find_files<cr>",
			desc = "Find files",
		},
		{
			"<leader>fg",
			"<cmd>Telescope live_grep<cr>",
			desc = "Live grep",
		},
		{
			"<leader>fb",
			"<cmd>Telescope buffers<cr>",
			desc = "Find buffers",
		},
		{
			"<leader>fh",
			"<cmd>Telescope help_tags<cr>",
			desc = "Help tags",
		},
		{
			"<leader>fr",
			"<cmd>Telescope oldfiles<cr>",
			desc = "Recent files",
		},
		{
			"<leader>fd",
			"<cmd>Telescope diagnostics<cr>",
			desc = "[F]ind [D]iagnostics",
		},
		{
			"<leader>fs",
			"<cmd>Telescope lsp_document_symbols<cr>",
			desc = "Document symbols",
		},
		{
			"<leader>fw",
			"<cmd>Telescope lsp_workspace_symbols<cr>",
			desc = "Workspace symbols",
		},
	},

	config = function()
		local telescope = require("telescope")
		local actions = require("telescope.actions")
		local action_layout = require("telescope.actions.layout")

		telescope.setup({
			defaults = {
				-- Default maximized horizontal layout (selector on left, wide preview on right)
				layout_strategy = "horizontal",
				layout_config = {
					width = 0.95,
					height = 0.95,
					horizontal = {
						preview_width = 0.65, -- 65% dedicated to preview pane
					},
					vertical = {
						preview_height = 0.5,
					},
				},

				path_display = {
					"truncate",
				},

				-- Unified controls applied across every picker
				mappings = {
					i = {
						["<C-j>"] = actions.move_selection_next,
						["<C-k>"] = actions.move_selection_previous,
						["<C-p>"] = action_layout.toggle_preview,
						["<C-h>"] = actions.select_horizontal,
						["<C-v>"] = actions.select_vertical,
						["<C-x>"] = actions.close,
					},
					n = {
						["q"] = actions.close,
						["<C-x>"] = actions.close,
						["<C-h>"] = actions.select_horizontal,
						["<C-v>"] = actions.select_vertical,
						["<C-p>"] = action_layout.toggle_preview,
					},
				},
			},
		})

		-- Load extension for faster sorting (fzf)
		telescope.load_extension("fzf")
	end,
}
