-- ============================================================================
-- Plugins: vim-dadbod, vim-dadbod-ui, vim-dadbod-completion
-- Purpose: Database management client, visual sidebar UI, and SQL completions.
--
-- Supported Databases:
--   PostgreSQL, MySQL, SQLite, MariaDB, Oracle, SQL Server, Redis, MongoDB, etc.
--
-- Keymaps (<leader>b group):
--   <leader>bu        - Toggle Database UI drawer (:DBUIToggle)
--   <leader>ba        - Add new database connection URL (:DBUIAddConnection)
--   <leader>bf        - Find/open active database query buffer (:DBUIFindBuffer)
--
-- DBUI Drawer Controls (when inside DBUI sidebar):
--   <CR> / o          - Expand / collapse database, schema, or table
--   S                 - Open table in split / execute query
--   d                 - Delete connection or saved query
--   R                 - Refresh database schema
--   q                 - Close DBUI sidebar
--   ?                 - Show in-drawer help cheatsheet
--
-- SQL Completions:
--   Automatically provides table and column name completions via blink.cmp
--   when editing .sql, .mysql, and .plsql files.
-- ============================================================================

return {
	-- Core database engine (executes queries and manages DB connections)
	{
		"tpope/vim-dadbod",
		lazy = true,
	},

	-- Graphical UI sidebar for exploring schemas and tables
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
			-- Enable Nerd Font icons in the database drawer
			vim.g.db_ui_use_nerd_fonts = 1
		end,
		keys = {
			{ "<leader>bu", "<cmd>DBUIToggle<cr>", desc = "Toggle Database UI" },
			{ "<leader>bf", "<cmd>DBUIFindBuffer<cr>", desc = "Find database buffer" },
			{ "<leader>ba", "<cmd>DBUIAddConnection<cr>", desc = "Add database connection" },
		},
	},

	-- Autocompletion source for SQL tables, columns, and keywords
	{
		"kristijanhusak/vim-dadbod-completion",
		ft = { "sql", "mysql", "plsql" },
		dependencies = { "tpope/vim-dadbod" },
		lazy = true,
	},
}
