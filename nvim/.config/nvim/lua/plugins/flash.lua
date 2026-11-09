-- ============================================================================
-- Plugin: flash.nvim
-- Purpose: Lightning-fast cursor navigation and text manipulation using 2D
--          search labels, Treesitter AST node selection, and remote operations.
--
-- Keymaps:
--   <leader>jk      (n)       - Flash Jump: Type search chars, then press label
--                               to instantly warp anywhere across visible windows.
--   <leader>jt      (n, x, o) - Flash Treesitter: Visual labels on syntax nodes
--                               (blocks, functions, arguments) to jump or select.
--   r               (o)       - Remote Flash: Perform an operator remotely without
--                               moving cursor (e.g., `yr<label>iw` yanks a word elsewhere).
--   <C-s>           (c)       - Toggle Flash labels while inside standard search (`/` or `?`).
--   f, F, t, T      (n)       - Enhanced inline motions: shows instant jump labels
--                               on repeated matches without pressing `;`.
-- ============================================================================

return {
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		opts = {
			labels = "asdfghjklqwertyuiopzxcvbnm",
			search = {
				multi_window = true, -- Search and jump across all open windows
				forward = true,
				wrap = true,
			},
			jump = {
				jumplist = true, -- Record jumps in Neovim jumplist (<C-o> / <C-i>)
			},
			label = {
				rainbow = {
					enabled = false,
				},
			},
			modes = {
				char = {
					enabled = true,
					jump_labels = true, -- Show direct jump labels on repeated f/t motions
				},
			},
		},
		config = function(_, opts)
			local flash = require("flash")
			flash.setup(opts)

			-- Jump anywhere across visible windows
			vim.keymap.set("n", "<leader>jk", function()
				flash.jump()
			end, { desc = "Flash Jump" })

			-- Jump to or select syntax nodes via Treesitter
			vim.keymap.set({ "n", "x", "o" }, "<leader>jt", function()
				flash.treesitter()
			end, { desc = "Flash Treesitter" })

			-- Remote operator-pending action (e.g. `yr`, `dr`, `cr`)
			vim.keymap.set("o", "r", function()
				flash.remote()
			end, { desc = "Remote Flash" })

			-- Toggle Flash search labels during standard / or ? searching
			vim.keymap.set("c", "<C-s>", function()
				flash.toggle()
			end, { desc = "Toggle Flash Search" })
		end,
	},
}
