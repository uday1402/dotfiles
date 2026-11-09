-- ============================================================================
-- Plugin: nvim-devdocs
-- Purpose: Offline DevDocs API documentation viewer inside Neovim powered by
--          Telescope search and Treesitter syntax highlighting.
--
-- Keymaps:
--   <leader>Do      (n) - Open documentation for current buffer filetype
--   <leader>Da      (n) - Open documentation picker across all installed docs
--   <leader>Df      (n) - Open current filetype doc in a floating window
--   <leader>DF      (n) - Open any installed doc in a floating window
--   <leader>Di      (n) - Install a new documentation set from DevDocs
--   <leader>Du      (n) - Uninstall an existing documentation set
--   <leader>Dx      (n) - Fetch / update documentation metadata index
--
-- Buffer Navigation (inside DevDocs view buffer):
--   q                   - Close documentation window
--
-- Commands:
--   :DevdocsOpenCurrent      - Search doc matching current filetype
--   :DevdocsOpen             - Search all installed documentation sets
--   :DevdocsOpenCurrentFloat - Search current filetype doc in floating popup
--   :DevdocsOpenFloat        - Search any installed doc in floating popup
--   :DevdocsInstall          - Interactive picker to download new docs
--   :DevdocsUninstall        - Interactive picker to remove installed docs
--   :DevdocsUpdate           - Update installed documentation sets
--   :DevdocsFetch            - Refresh metadata catalog from devdocs.io
-- ============================================================================

return {
	"luckasRanarison/nvim-devdocs",

	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim",
		"nvim-treesitter/nvim-treesitter",
	},

	keys = {
		-- Search docs matching the active filetype in a full split
		{
			"<leader>Do",
			"<cmd>DevdocsOpenCurrent<cr>",
			desc = "DevDocs: Open for current filetype",
		},
		-- Search across all installed documentation sets in a full split
		{
			"<leader>Da",
			"<cmd>DevdocsOpen<cr>",
			desc = "DevDocs: Open (all installed)",
		},
		-- Search active filetype docs inside a centered floating window
		{
			"<leader>Df",
			"<cmd>DevdocsOpenCurrentFloat<cr>",
			desc = "DevDocs: Open float (current filetype)",
		},
		-- Search any installed docs inside a centered floating window
		{
			"<leader>DF",
			"<cmd>DevdocsOpenFloat<cr>",
			desc = "DevDocs: Open float (all installed)",
		},
		-- Browse and download documentation sets from DevDocs catalog
		{
			"<leader>Di",
			"<cmd>DevdocsInstall<cr>",
			desc = "DevDocs: Install docs",
		},
		-- Remove previously installed documentation set
		{
			"<leader>Du",
			"<cmd>DevdocsUninstall<cr>",
			desc = "DevDocs: Uninstall docs",
		},
		-- Refresh available documentation metadata and versions from DevDocs
		{
			"<leader>Dx",
			"<cmd>DevdocsFetch<cr>",
			desc = "DevDocs: Fetch/update metadata",
		},
	},

	opts = {
		-- Automatically install and ensure these documentation sets exist offline
		ensure_installed = {
			"python-3.12",
			"javascript",
			"html",
			"css",
			"c",
			"cpp",
		},

		-- Map Neovim filetypes to DevDocs documentation slugs so that
		-- :DevdocsOpenCurrent / <leader>Do knows which docset to open.
		filetypes = {
			python = "python-3.12",
			javascript = "javascript",
			html = "html",
			css = "css",
			c = "c",
			cpp = "cpp",
		},

		-- Floating window dimensions and styling for :DevdocsOpen*Float commands
		float_win = {
			relative = "editor",
			height = 25,
			width = 100,
			border = "rounded",
		},

		wrap = false, -- Disable line wrap in doc buffers

		-- Preview pane in the Telescope picker (shows doc content inline)
		previewer_cmd = nil, -- Optional external renderer (e.g., "glow") if installed
		cmd_args = {},

		-- Callback triggered when a doc buffer is opened
		after_open = function(bufnr)
			-- Press 'q' to close the documentation buffer quickly
			vim.api.nvim_buf_set_keymap(bufnr, "n", "q", ":close<cr>", { silent = true })
		end,
	},
}
