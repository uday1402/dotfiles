-- ============================================================================
-- Plugin: nvim-treesitter-context
-- Purpose: "Sticky scroll" header showing the current function, class, loop, or
--          scope definition pinned at the top of the screen as you scroll down.
--
-- How It Works:
--   When scrolling through a long function or nested block, the header line
--   (e.g., function definition, class declaration) sticks to the very top row
--   so you never lose track of where you are in the code.
--
-- Context Navigation:
--   Jump to the pinned context header: [c (or :lua require("treesitter-context").go_to_context())
-- ============================================================================

return {
	"nvim-treesitter/nvim-treesitter-context",
	event = "VeryLazy",
	opts = {
		-- Enable sticky context headers
		enable = true,

		-- Maximum number of lines the pinned context header can occupy
		max_lines = 3,

		-- Only activate sticky headers in windows with at least this many rows
		min_window_height = 20,

		-- Display matching line numbers in the gutter for pinned context lines
		line_numbers = true,

		-- Maximum lines to display for multiline definitions (e.g. long parameter lists)
		multiline_threshold = 2,

		-- Trim behavior when exceeding max_lines: 'outer' drops outer scopes first
		trim_scope = "outer",

		-- Calculate context based on 'cursor' position (follows cursor as you edit)
		mode = "cursor",

		-- Optional separator character below pinned header (nil = clean border)
		separator = nil,

		-- Floating window z-index
		zindex = 20,
	},
}
