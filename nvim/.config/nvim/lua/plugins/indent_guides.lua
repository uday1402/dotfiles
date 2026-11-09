-- ============================================================================
-- Plugin: indent-blankline.nvim (ibl)
-- Purpose: Visual indentation guides and Treesitter-based active scope highlighting
--          to navigate nested code blocks effortlessly.
--
-- Commands:
--   :IBLToggle        - Toggle indentation guides globally
--   :IBLToggleScope   - Toggle active scope indentation guide
--   :IBLEnable        - Turn on indent guides
--   :IBLDisable       - Turn off indent guides
--
-- Features:
--   - Vertical line markers ('│') aligned to shiftwidth tabs / spaces
--   - Active scope tracking: highlights current block/function using Treesitter
--   - Automatic exclusion on utility buffers, dashboards, and floating windows
-- ============================================================================

return {
	{
		"lukas-reineke/indent-blankline.nvim",

		main = "ibl",

		event = "VeryLazy",

		config = function()
			require("ibl").setup({
				indent = {
					-- Character used to render vertical indentation guides
					char = "│",
				},

				scope = {
					-- Highlight the current code block / function scope using Treesitter
					enabled = true,

					-- Disable horizontal start/end boundary lines to keep editor clean
					show_start = false,
					show_end = false,
				},

				whitespace = {
					-- Keep trail rendering consistent on blank lines
					remove_blankline_trail = false,
				},

				exclude = {
					-- Suppress indentation guides on utility panels, dashboards, and popups
					filetypes = {
						"help",
						"alpha",
						"dashboard",
						"neo-tree",
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
