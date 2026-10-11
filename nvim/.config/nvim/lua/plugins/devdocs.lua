-- nvim-devdocs: offline DevDocs documentation inside Neovim via Telescope
return {
	"luckasRanarison/nvim-devdocs",

	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim",
		"nvim-treesitter/nvim-treesitter",
	},

	keys = {
		-- Open documentation for the current filetype
		{
			"<leader>Do",
			"<cmd>DevdocsOpenCurrent<cr>",
			desc = "DevDocs: Open for current filetype",
		},
		-- Open documentation picker (choose any installed doc)
		{
			"<leader>Da",
			"<cmd>DevdocsOpen<cr>",
			desc = "DevDocs: Open (all installed)",
		},
		-- Search documentation for the current filetype in a float
		{
			"<leader>Df",
			"<cmd>DevdocsOpenCurrentFloat<cr>",
			desc = "DevDocs: Open float (current filetype)",
		},
		-- Search all installed docs in a float
		{
			"<leader>DF",
			"<cmd>DevdocsOpenFloat<cr>",
			desc = "DevDocs: Open float (all installed)",
		},
		-- Install a new documentation set
		{
			"<leader>Di",
			"<cmd>DevdocsInstall<cr>",
			desc = "DevDocs: Install docs",
		},
		-- Uninstall documentation
		{
			"<leader>Du",
			"<cmd>DevdocsUninstall<cr>",
			desc = "DevDocs: Uninstall docs",
		},
		-- Fetch / update documentation metadata
		{
			"<leader>Dx",
			"<cmd>DevdocsFetch<cr>",
			desc = "DevDocs: Fetch/update metadata",
		},
	},

	opts = {
		-- Automatically install these documentation sets on first load
		ensure_installed = {
			"python-3.12",
			"javascript",
			"html",
			"css",
			"c",
			"cpp",
		},

		-- Map Neovim filetypes → devdocs documentation names so that
		-- :DevdocsOpenCurrent knows which docs to search.
		filetypes = {
			python = "python-3.12",
			javascript = "javascript",
			html = "html",
			css = "css",
			c = "c",
			cpp = "cpp",
		},

		-- Floating window appearance for :DevdocsOpen*Float commands
		float_win = {
			relative = "editor",
			height = 25,
			width = 100,
			border = "rounded",
		},

		wrap = false,

		-- Preview pane in the Telescope picker (shows doc content inline)
		previewer_cmd = nil, -- set to "glow" if you have it installed
		cmd_args = {},

		after_open = function(bufnr)
			-- Press 'q' to close the documentation buffer quickly
			vim.api.nvim_buf_set_keymap(bufnr, "n", "q", ":close<cr>", { silent = true })
		end,
	},
}
