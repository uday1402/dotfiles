return {
	"folke/trouble.nvim",
	opts = {}, -- for default options, refer to the configuration section for custom setup.
	cmd = "Trouble",
	keys = {
		{
			"<leader>xx",
			"<cmd>Trouble diagnostics toggle<cr>",
			desc = "Diagnostics (Trouble)",
		},
		{
			"<leader>xX",
			"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
			desc = "Buffer Diagnostics (Trouble)",
		},
		{
			"<leader>xs",
			"<cmd>Trouble symbols toggle focus=false<cr>",
			desc = "Symbols (Trouble)",
		},
		{
			"<leader>xl",
			"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
			desc = "LSP Definitions / references / ... (Trouble)",
		},
		{
			"<leader>xL",
			function()
				-- Location list is empty until filled; load buffer diagnostics into it first
				vim.diagnostic.setloclist({ open = false })
				vim.cmd("Trouble loclist toggle")
			end,
			desc = "Location List (Trouble)",
		},
		{
			"<leader>xq",
			function()
				-- Quickfix list is empty until filled; load diagnostics into it first
				vim.diagnostic.setqflist({ open = false })
				vim.cmd("Trouble qflist toggle")
			end,
			desc = "Quickfix List (Trouble)",
		},
	},
}
