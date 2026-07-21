-- treesitter context for functions and nestings

return {
	"nvim-treesitter/nvim-treesitter-context",
	event = "VeryLazy",
	opts = {
		enable = true,
		max_lines = 3, -- if it goes beyond this, flatten your code
		min_window_height = 20,
		line_numbers = true,
		multiline_threshold = 2,
		trim_scope = "outer",
		mode = "cursor", -- follows the cursor
		separator = nil,
		zindex = 20,
	},
}
