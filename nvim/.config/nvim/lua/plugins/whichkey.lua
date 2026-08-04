return {
	{
		"folke/which-key.nvim",
		event = "VimEnter",
		---@module 'which-key'
		---@type wk.Opts
		opts = {
			delay = 0,

			preset = "helix",

			icons = {
				mappings = vim.g.have_nerd_font,
			},

			win = {
				border = "rounded",
				row = math.huge,
				col = math.huge,

				padding = {
					1,
					2,
				},
			},

			spec = {
				{ "<leader>t", group = "[T]oggle" },
				{ "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
				{ "<leader>d", group = "[D]ebug / Diagnostics", mode = { "n" } },
				{ "<leader>b", group = "[B]atabase", mode = { "n" } },
				{ "<leader>f", group = "[F]ind", mode = { "n", "v" } },
				{ "<leader>s", group = "[S]plit", mode = { "n", "v" } },
				{ "<leader>x", group = "LSP", mode = { "n", "v" } },
				{ "gr", group = "LSP Actions", mode = { "n" } },
			},
		},
	},
}
