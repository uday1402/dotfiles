return {
	{
		"tpope/vim-dadbod",
		lazy = true,
	},
	{
		"kristijanhusak/vim-dadbod-ui",
		cmd = {
			"DBUI",
			"DBUIToggle",
			"DBUIAddConnection",
			"DBUIFindBuffer",
		},
		dependencies = {
			{ "tpope/vim-dadbod", lazy = true },
		},
		init = function()
			vim.g.db_ui_use_nerd_fonts = 1
		end,
		keys = {
			{ "<leader>bu", "<cmd>DBUIToggle<cr>", desc = "Database UI" },
			{ "<leader>bf", "<cmd>DBUIFindBuffer<cr>", desc = "Find database buffer" },
			{ "<leader>ba", "<cmd>DBUIAddConnection<cr>", desc = "Add database connection" },
		},
	},
	{
		"kristijanhusak/vim-dadbod-completion",
		ft = { "sql", "mysql", "plsql" },
		dependencies = { "tpope/vim-dadbod" },
		lazy = true,
	},
}
