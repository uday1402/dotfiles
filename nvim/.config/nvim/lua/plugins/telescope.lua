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

		telescope.setup({
			defaults = {
				path_display = {
					"truncate",
				},
			},

			pickers = {
				find_files = {
					mappings = {
						n = {
							["q"] = actions.close,
						},
					},
				},
				live_grep = {
					mappings = {
						n = {
							["q"] = actions.close,
						},
					},
				},
				buffers = {
					mappings = {
						n = {
							["q"] = actions.close,
						},
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
