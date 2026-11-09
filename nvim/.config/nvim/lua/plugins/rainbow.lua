-- ============================================================================
-- Plugin: rainbow-delimiters.nvim
-- Purpose: Treesitter-powered alternating colors for nested parentheses, brackets,
--          braces, and HTML/XML tags to make nested structures instantly readable.
--
-- Commands:
--   :RainbowDelimitersToggle       - Toggle rainbow colors for the current buffer
--   :RainbowDelimitersToggleGlobal - Toggle rainbow colors across all buffers
--   :RainbowDelimitersEnable       - Force enable for current buffer
--   :RainbowDelimitersDisable      - Force disable for current buffer
--
-- Features:
--   - Accurate delimiter pair tracking via Treesitter AST parsing
--   - Alternating highlight groups based on nesting level:
--     RainbowDelimiterRed, RainbowDelimiterYellow, RainbowDelimiterBlue,
--     RainbowDelimiterOrange, RainbowDelimiterGreen, RainbowDelimiterViolet,
--     RainbowDelimiterCyan
--   - Seamless integration with colorschemes (Catppuccin, Tokyonight, etc.)
-- ============================================================================

return {
	"HiPhish/rainbow-delimiters.nvim",
	-- Load on buffer read or new file creation for syntax-highlighted buffers
	event = { "BufReadPost", "BufNewFile" },

	config = function()
		local defaults = require("rainbow-delimiters.default")

		require("rainbow-delimiters.setup").setup({
			-- Use default delimiter priority table.
			-- Explicitly setting this prevents :checkhealth from reporting an empty priority table warning.
			priority = {
				[""] = defaults.priority[""],
			},
		})
	end,
}
