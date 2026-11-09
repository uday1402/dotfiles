-- ============================================================================
-- Plugin: neo-tree.nvim (v3)
-- Purpose: Project sidebar file explorer with Git status and LSP diagnostics.
--
-- Global Shortcuts:
--   <leader>e         - Toggle file explorer sidebar (:Neotree toggle)
--   <leader>o         - Focus and reveal current file in explorer (:Neotree focus reveal)
--
-- Tree Controls (active when inside the Neo-tree window):
--   <CR>              - Open file / toggle directory open/close
--   s                 - Open selected file in a horizontal split
--   v                 - Open selected file in a vertical split
--   t                 - Open selected file in a new tab
--   P                 - Toggle file preview pane
--   a                 - Add new file (append '/' to create a directory)
--   d                 - Delete file or directory (prompts confirmation)
--   r                 - Rename file or directory
--   c                 - Copy file
--   m                 - Move / cut file
--   p                 - Paste copied or cut file
--   y                 - Copy file name to clipboard
--   Y                 - Copy relative path to clipboard
--   H                 - Toggle hidden dotfiles (.env, .gitignore, etc.)
--   I                 - Toggle gitignored files visibility
--   R                 - Refresh explorer file tree
--   q                 - Close Neo-tree window
--   ?                 - Open built-in Neo-tree help cheatsheet
-- ============================================================================

return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",

		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},

		cmd = "Neotree",

		keys = {
			{ "<leader>e", "<cmd>Neotree toggle<CR>", desc = "Toggle file explorer" },
			{ "<leader>o", "<cmd>Neotree focus reveal<CR>", desc = "Reveal current file in explorer" },
		},

		config = function()
			require("neo-tree").setup({
				-- Automatically close Neo-tree if it is the last window remaining open
				close_if_last_window = true,
				popup_border_style = "rounded",

				-- Show Git change indicators and LSP diagnostics inline next to filenames
				enable_git_status = true,
				enable_diagnostics = true,

				filesystem = {
					-- Automatically highlight and expand to active buffer when switching files
					follow_current_file = {
						enabled = true,
					},
					-- Replace Vim's built-in netrw when opening directories (e.g. nvim .)
					hijack_netrw_behavior = "open_current",

					filtered_items = {
						visible = false,
						hide_dotfiles = false, -- Show hidden files (e.g. .gitignore, dotfiles) by default
						hide_gitignored = false, -- Show gitignored files by default
					},
				},

				window = {
					position = "left",
					width = 32,

					mappings = {
						["<space>"] = "none", -- Disable leader key forwarding inside tree
						["s"] = "open_split", -- Open file in horizontal split
						["v"] = "open_vsplit", -- Open file in vertical split
						["R"] = "refresh", -- Refresh file tree
					},
				},
			})
		end,
	},
}
