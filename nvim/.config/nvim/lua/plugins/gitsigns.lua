return {
	{ -- Adds git related signs to the gutter, as well as utilities for managing changes
		"lewis6991/gitsigns.nvim",
		---@module 'gitsigns'
		---@type Gitsigns.Config
		---@diagnostic disable-next-line: missing-fields

		opts = {
			-- Git Signs
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "-" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},

			-- Current Line Blame
			current_line_blame = false,

			-- Attach Keymaps
			on_attach = function(bufnr)
				local gitsigns = require("gitsigns")

				local map = function(mode, lhs, rhs, desc)
					vim.keymap.set(mode, lhs, rhs, {
						buffer = bufnr,
						desc = desc,
					})
				end

				-- Navigation
				-- map('n', ']h', gitsigns.next_hunk, 'Next git hunk')
				-- map('n', '[h', gitsigns.prev_hunk, 'Previous git hunk')

				-- Hunk Actions
				map("n", "<leader>ghs", gitsigns.stage_hunk, "Stage hunk")
				map("n", "<leader>ghr", gitsigns.reset_hunk, "Reset hunk")

				-- Visual Mode Hunk Actions
				map("v", "<leader>ghs", function()
					gitsigns.stage_hunk({
						vim.fn.line("."),
						vim.fn.line("v"),
					})
				end, "Stage selected hunk")

				map("v", "<leader>ghr", function()
					gitsigns.reset_hunk({
						vim.fn.line("."),
						vim.fn.line("v"),
					})
				end, "Reset selected hunk")

				-- Buffer Actions
				map("n", "<leader>ghS", gitsigns.stage_buffer, "Stage buffer")
				map("n", "<leader>ghR", gitsigns.reset_buffer, "Reset buffer")

				-- Preview
				map("n", "<leader>ghp", gitsigns.preview_hunk, "Preview hunk")

				-- Git Blame
				map("n", "<leader>ghb", gitsigns.blame_line, "Blame line")

				-- Diff
				map("n", "<leader>ghd", gitsigns.diffthis, "Diff against index")

				-- Toggle Features
				map("n", "<leader>tb", gitsigns.toggle_current_line_blame, "Toggle git blame")

				-- map(
				--     'n',
				--     '<leader>td',
				--     gitsigns.toggle_deleted,
				--     'Toggle deleted lines'
				-- )
			end,
		},
	},
}
