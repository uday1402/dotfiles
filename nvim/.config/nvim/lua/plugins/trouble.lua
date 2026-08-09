-- - <CR> — jump
-- - o — jump and close
-- - q — close
-- - r — refresh
-- - p — preview
-- - ] / [ — next/previous item
-- - ? — help
return {
	{
		"folke/trouble.nvim",
		cmd = "Trouble",
		opts = {},
		keys = {
			{
				"<leader>xd",
				"<cmd>Trouble diagnostics toggle<cr>",
				desc = "Workspace diagnostics (Trouble)",
			},
			{
				"<leader>xD",
				"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
				desc = "Buffer diagnostics (Trouble)",
			},
			{
				"<leader>xS",
				"<cmd>Trouble symbols toggle focus=false win.position=right<cr>",
				desc = "Document symbols (Trouble)",
			},
			{
				"<leader>xL",
				"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
				desc = "LSP locations (Trouble)",
			},
			{
				"<leader>xR",
				"<cmd>Trouble lsp_references toggle focus=false<cr>",
				desc = "LSP references (Trouble)",
			},
			{
				"<leader>xI",
				"<cmd>Trouble lsp_implementations toggle focus=false<cr>",
				desc = "LSP implementations (Trouble)",
			},
			{
				"<leader>xq",
				"<cmd>Trouble qflist toggle<cr>",
				desc = "Quickfix list (Trouble)",
			},
			{
				"<leader>xQ",
				"<cmd>Trouble loclist toggle<cr>",
				desc = "Location list (Trouble)",
			},
		},
	},
}
