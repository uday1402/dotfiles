-- ============================================================================
-- Plugin: todo-comments.nvim
-- Purpose: Highlights and searches for TODO-style keywords inside code comments.
--
-- Syntax Requirement:
--   The keyword (or its alias) must be inside a comment and followed by a COLON (:).
--   Examples:
--     -- TODO: implement user authentication
--     // BUG: crashes when array is empty
--     # HACK: temporary workaround for upstream bug
--     /* PERF: optimize nested loop */
--
-- Supported Keyword Hooks & Aliases:
--   Keyword   Aliases                          Color / Severity
--   -------   ------------------------------   ------------------------------
--   FIX:      FIXME:, BUG:, FIXIT:, ISSUE:     Critical bugs / broken code (Red)
--   TODO:     (none)                           Pending tasks / features (Blue)
--   HACK:     (none)                           Workarounds / tech debt (Yellow)
--   WARN:     WARNING:, XXX:                   Risks / cautionary notes (Yellow)
--   PERF:     OPTIM:, PERFORMANCE:, OPTIMIZE:  Performance / bottlenecks (Purple)
--   NOTE:     INFO:                            General context / reminders (Green)
--   TEST:     TESTING:, PASSED:, FAILED:       Test cases / assertions (Magenta)
--
-- Keymaps & Commands:
--   <leader>ft                       - Open Telescope search for all project todos
--   ]t                               - Jump to next todo comment in current buffer
--   [t                               - Jump to previous todo comment in current buffer
--   :TodoTelescope keywords=TODO,FIX - Filter Telescope by specific keywords
--   :Trouble todo toggle             - Open project todos in a Trouble panel
--   :TodoQuickFix                    - Load all todos into Neovim's quickfix list
--   :TodoLocList                     - Load all todos into window's location list
-- ============================================================================

return {
	{
		"folke/todo-comments.nvim",
		event = "VeryLazy",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		opts = {},
		keys = {
			{
				"<leader>ft",
				"<cmd>TodoTelescope<cr>",
				desc = "Todo Comments (Telescope)",
			},
			{
				"]t",
				function()
					require("todo-comments").jump_next()
				end,
				desc = "Next todo comment",
			},
			{
				"[t",
				function()
					require("todo-comments").jump_prev()
				end,
				desc = "Previous todo comment",
			},
		},
	},
}
