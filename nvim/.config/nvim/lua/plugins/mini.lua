-- ============================================================================
-- Plugin: mini.nvim
-- Purpose: Collection of fast, modular Neovim utilities bundled into one suite.
--
-- Enabled Modules & Controls:
--
-- 1. mini.surround (Surround Actions):
--    • sa<motion><char> - [A]dd surrounding pair (e.g. saiw" surrounds word with ")
--    • sd<char>         - [D]elete surrounding pair (e.g. sd" removes surrounding ")
--    • sr<old><new>     - [R]eplace surrounding pair (e.g. sr"' changes " to ')
--    • sh<char>         - [H]ighlight surrounding pair
--
-- 2. mini.move (Line & Selection Dragging):
--    • <M-j> / <M-k>    - Move current line or visual selection Down / Up
--    • <M-h> / <M-l>    - Shift current line or visual selection Left / Right
--
-- 3. mini.ai (Enhanced Text Objects):
--    • a) / i)          - Around / inside parentheses ()
--    • aq / iq          - Around / inside quotes ('', "", ``)
--    • ab / ib          - Around / inside any bracket pair ((), [], {})
--    • aa / ia          - Around / inside argument/parameter
--
-- 4. mini.pairs (Autopairs):
--    • Automatically inserts and balances closing (), [], {}, "", '', ``
--
-- 5. mini.animate (Smooth Animations):
--    • Smooth scrolling (<C-u>/<C-d>) and window open/close/resize animations
-- ============================================================================

return {
	{
		"echasnovski/mini.nvim",
		version = false,

		config = function()
			local animate = require("mini.animate")

			-- Enhanced text objects: 'aq'/'iq' for quotes, 'ab'/'ib' for brackets, 'aa'/'ia' for args
			require("mini.ai").setup()

			-- Surround management: 'sa' (add), 'sd' (delete), 'sr' (replace)
			require("mini.surround").setup()

			-- Autopairs: auto-closes brackets, quotes, and backticks in insert mode
			require("mini.pairs").setup()

			-- Smooth animations for scrolling, window resizing, and split open/close
			animate.setup({
				cursor = {
					-- Disabled; cursor trail animation is handled by smear-cursor.nvim
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
			})

			-- Line and block dragging: Alt + h/j/k/l moves lines or selections in any direction
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
			})
		end,
	},
}
