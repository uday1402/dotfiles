-- ============================================================================
-- Plugin: which-key.nvim (v3)
-- Purpose: Interactive popup cheatsheet that displays available keybindings and
--          sub-commands in real time as you press key prefixes.
--
-- How to Use:
--   - Press <leader> (Space) in Normal/Visual mode to show top-level key groups.
--   - Press any configured prefix (e.g., <leader>f, <leader>x, gr) to see all
--     commands registered under that group.
--   - Run :WhichKey to interactively search through all registered keymaps.
--
-- Popup Controls (when which-key window is visible):
--   <BS>      - Go back to the previous key group level
--   <Esc>     - Dismiss / cancel the cheatsheet popup
-- ============================================================================

return {
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		---@module 'which-key'
		---@type wk.Opts
		opts = {
			delay = 0,

			preset = "helix",

			icons = {
				mappings = vim.g.have_nerd_font,
			},

			win = {
				border = "rounded",
				row = math.huge,
				col = math.huge,

				padding = {
					1,
					2,
				},
			},

			spec = {
				{ "<leader>t", group = "[T]oggle" },
				{ "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
				{ "<leader>d", group = "[D]ebug / Diagnostics", mode = { "n" } },
				{ "<leader>b", group = "[B]atabase", mode = { "n" } },
				{ "<leader>f", group = "[F]ind", mode = { "n", "v" } },
				{ "<leader>s", group = "[S]plit", mode = { "n", "v" } },
				{ "<leader>x", group = "LSP", mode = { "n", "v" } },
				{ "<leader>i", group = "[A]I Assistant", mode = { "n", "v" } },
				{ "gr", group = "LSP Actions", mode = { "n" } },
				{ "<leader>D", group = "[D]evDocs", mode = { "n" } },
				{ "<leader>m", group = "[M]arkdown", mode = { "n" } },
				{ "<leader>T", group = "[T]erminal", mode = { "n" } },
			},
		},
	},
}
