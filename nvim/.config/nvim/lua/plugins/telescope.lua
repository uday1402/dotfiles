return {
	"nvim-telescope/telescope.nvim",

	-- master works with nvim-treesitter main (0.1.x still calls removed ft_to_lang)
	branch = "master",

	cmd = "Telescope",

	dependencies = {
		"nvim-lua/plenary.nvim",

		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
		},

		"nvim-telescope/telescope-ui-select.nvim", -- adds additional features such as recent files, symbols, help tags etc
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
				layout_strategy = "horizontal",

				layout_config = {
					horizontal = { preview_width = 0.65 },
					vertical = { preview_height = 0.5 },
					width = 0.95,
					height = 0.95,
				},

				-- Cycle through these preset layouts with <C-l>:
				--   1. Default   – side-by-side, 87×80 %, 55 % preview
				--   2. Maximized – nearly full screen, 65 % preview
				--   3. Vertical  – stacked, top results / bottom preview
				cycle_layout_list = {
					{
						layout_strategy = "horizontal",
						layout_config = {
							width = 0.87,
							height = 0.80,
							preview_width = 0.55,
						},
					},
					{
						layout_strategy = "horizontal",
						layout_config = {
							width = 0.95,
							height = 0.95,
							preview_width = 0.65,
						},
					},
					{
						layout_strategy = "vertical",
						layout_config = {
							width = 0.80,
							height = 0.90,
							preview_height = 0.55,
						},
					},
				},

				path_display = {
					"truncate",
				},

				-- Mappings applied to EVERY picker (find_files, live_grep,
				-- devdocs, etc.) so they all behave consistently.
				mappings = {
					i = {
						["<C-p>"] = action_layout.toggle_preview,
						["<C-l>"] = action_layout.cycle_layout_next,
						["<C-j>"] = actions.move_selection_next,
						["<C-k>"] = actions.move_selection_previous,
					},
					n = {
						["q"] = actions.close,
						["<C-p>"] = action_layout.toggle_preview,
						["<C-l>"] = action_layout.cycle_layout_next,
					},
				},
			},

			extensions = {
				["ui-select"] = {
					require("telescope.themes").get_dropdown(),
				},
			},
		})

		telescope.load_extension("fzf")
		telescope.load_extension("ui-select")
	end,
}
