return {
	{
		"lukas-reineke/indent-blankline.nvim",

		main = "ibl",

		event = "VeryLazy",

		config = function()
			-- This plugin provides:
			--
			-- - indentation guides
			-- - scope highlighting
			-- - visual nesting structure

			require("ibl").setup({
				indent = {
					char = "│",
				},

				scope = {
					enabled = true,

					show_start = false,
					show_end = false,
				},

				whitespace = {
					remove_blankline_trail = false,
				},

				exclude = {
					filetypes = {
						"help",
						"alpha",
						"dashboard",
						"neo-tree",
						"Trouble",
						"lazy",
						"mason",
						"notify",
						"toggleterm",
					},
				},
			})
		end,
	},
}
