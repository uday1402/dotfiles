-- ============================================================================
-- Plugin: trouble.nvim (v3)
-- Purpose: Pretty lists for diagnostics, references, symbols, and quickfix lists.
--
-- Buffer Navigation (active when cursor is inside a Trouble window):
--   <CR>     - Jump to code location
--   o        - Jump to code location and close Trouble window
--   q        - Close Trouble window
--   r        - Refresh list
--   p        - Toggle/open preview pane
--   ] / [    - Navigate to next / previous item
--   ?        - Toggle in-buffer help menu / keybinding cheatsheet
-- ============================================================================

return {
	{
		"folke/trouble.nvim",
		cmd = "Trouble",
		opts = {},
		keys = {
			-- Workspace diagnostics:
			-- Shows all LSP errors, warnings, and hints across the entire project.
			{
				"<leader>xd",
				"<cmd>Trouble diagnostics toggle<cr>",
				desc = "Workspace diagnostics (Trouble)",
			},

			-- Buffer diagnostics:
			-- `filter.buf=0` restricts the diagnostics list strictly to the active buffer.
			{
				"<leader>xD",
				"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
				desc = "Buffer diagnostics (Trouble)",
			},

			-- Document symbols outline:
			-- Shows functions, classes, and variables in the current file.
			-- `win.position=right`: opens as an outline sidebar on the right side.
			-- `focus=false`: keeps cursor in the editor so typing is not interrupted.
			{
				"<leader>xS",
				"<cmd>Trouble symbols toggle focus=false win.position=right<cr>",
				desc = "Document symbols (Trouble)",
			},
			-- Combined LSP locations:
			-- Aggregates definitions, references, implementations, type definitions, etc.
			-- Placed in a right sidebar without taking editor focus.
			{
				"<leader>xL",
				"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
				desc = "LSP locations (Trouble)",
			},
			-- LSP references:
			-- Lists all usages/references of the symbol under the cursor.
			-- `focus=false`: keeps editor focused while viewing references at the bottom.
			{
				"<leader>xR",
				"<cmd>Trouble lsp_references toggle focus=false<cr>",
				desc = "LSP references (Trouble)",
			},
			-- LSP implementations:
			-- Lists implementations for the interface/class under the cursor.
			-- `focus=false`: maintains focus in your code window.
			{
				"<leader>xI",
				"<cmd>Trouble lsp_implementations toggle focus=false<cr>",
				desc = "LSP implementations (Trouble)",
			},
			-- Quickfix list:
			-- Displays Neovim's standard global quickfix list (:copen) in Trouble's UI.
			{
				"<leader>xq",
				"<cmd>Trouble qflist toggle<cr>",
				desc = "Quickfix list (Trouble)",
			},
			-- Location list:
			-- Displays the current window's local location list (:lopen) in Trouble's UI.
			{
				"<leader>xQ",
				"<cmd>Trouble loclist toggle<cr>",
				desc = "Location list (Trouble)",
			},
		},
	},
}
