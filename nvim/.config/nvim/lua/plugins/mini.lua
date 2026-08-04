return {
	{
		"echasnovski/mini.nvim",
		version = false,

		config = function()
			local animate = require("mini.animate")

			require("mini.ai").setup() -- aw, iw, q, b

			require("mini.surround").setup() -- use :help mini.surround

			require("mini.pairs").setup() -- autopairs

			animate.setup({
				cursor = {
					enable = false,
				},

				scroll = {
					enable = true,
					timing = function(_, step_count)
						return 180 / step_count
					end,
					subscroll = animate.gen_subscroll.equal({ max_output_steps = 12 }),
				},

				resize = {
					enable = true,
				},

				open = {
					enable = true,
				},

				close = {
					enable = true,
				},
			}) -- gcc, gc to comment lines

			require("mini.comment").setup({
				options = {
					custom_commentstring = nil,
					ignore_blank_line = false,
				},
			}) -- gcc, gc to comment lines

			require("mini.move").setup({
				mappings = {
					left = "<M-h>",
					right = "<M-l>",
					down = "<M-j>",
					up = "<M-k>",

					line_left = "<M-h>",
					line_right = "<M-l>",
					line_down = "<M-j>",
					line_up = "<M-k>",
				},
			}) -- move line(s) by alt j/k
		end,
	},
}
