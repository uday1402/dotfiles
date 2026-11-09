-- ============================================================================
-- Plugin: gitsigns.nvim
-- Purpose: Superfast Git decorations integrated into the sign column, buffer
--          diff inspection, hunk staging/resetting, and inline blame.
--
-- Sign Column Indicators:
--   +  - Line(s) added
--   ~  - Line(s) modified
--   -  - Line(s) deleted
--   ‾  - Line(s) deleted above the top of the file
--
-- Keymaps:
--   <leader>ghs (n, v) - Stage hunk (or selected lines in visual mode)
--   <leader>ghr (n, v) - Reset hunk (discard changes in hunk or visual selection)
--   <leader>ghS (n)    - Stage entire buffer
--   <leader>ghR (n)    - Reset entire buffer
--   <leader>ghp (n)    - Preview hunk diff in a floating window
--   <leader>ghb (n)    - Show full git blame commit info for current line in popup
--   <leader>ghd (n)    - Open vimdiff split against git index
--   <leader>tb  (n)    - Toggle real-time inline git blame virtual text
-- ============================================================================

return {
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		---@module 'gitsigns'
		---@type Gitsigns.Config
		---@diagnostic disable-next-line: missing-fields

		opts = {
			-- Git Signs in the sign column / gutter
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "-" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},

			-- Current Line Blame (disabled on start, toggleable with <leader>tb)
			current_line_blame = false,

			-- Attach Keymaps buffer-locally when a Git buffer is loaded
			on_attach = function(bufnr)
				local gitsigns = require("gitsigns")

				local map = function(mode, lhs, rhs, desc)
					vim.keymap.set(mode, lhs, rhs, {
						buffer = bufnr,
						desc = desc,
					})
				end

				-- Hunk Actions (Normal Mode)
				map("n", "<leader>ghs", gitsigns.stage_hunk, "Git: Stage hunk")
				map("n", "<leader>ghr", gitsigns.reset_hunk, "Git: Reset hunk")

				-- Hunk Actions (Visual Mode)
				map("v", "<leader>ghs", function()
					gitsigns.stage_hunk({
						vim.fn.line("."),
						vim.fn.line("v"),
					})
				end, "Git: Stage selected hunk")

				map("v", "<leader>ghr", function()
					gitsigns.reset_hunk({
						vim.fn.line("."),
						vim.fn.line("v"),
					})
				end, "Git: Reset selected hunk")

				-- Buffer-wide Actions
				map("n", "<leader>ghS", gitsigns.stage_buffer, "Git: Stage buffer")
				map("n", "<leader>ghR", gitsigns.reset_buffer, "Git: Reset buffer")

				-- Inspection & Diff
				map("n", "<leader>ghp", gitsigns.preview_hunk, "Git: Preview hunk")
				map("n", "<leader>ghb", gitsigns.blame_line, "Git: Blame line")
				map("n", "<leader>ghd", gitsigns.diffthis, "Git: Diff against index")

				-- Toggles
				map("n", "<leader>tb", gitsigns.toggle_current_line_blame, "Toggle git blame")
			end,
		},
	},
}
