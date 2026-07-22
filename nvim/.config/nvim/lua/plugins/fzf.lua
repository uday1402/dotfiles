local diagnostic_icons = {
	[vim.diagnostic.severity.ERROR] = " ",
	[vim.diagnostic.severity.WARN] = " ",
	[vim.diagnostic.severity.INFO] = " ",
	[vim.diagnostic.severity.HINT] = "󰌵 ",
}

local function diagnostics_to_quickfix()
	vim.diagnostic.setqflist({
		open = false,
		title = "Workspace diagnostics",
	})
	require("fzf-lua").quickfix()
end

local function diagnostics_to_loclist()
	vim.diagnostic.setloclist({
		open = false,
		title = "Buffer diagnostics",
	})
	require("fzf-lua").loclist()
end

return {
	"ibhagwan/fzf-lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	cmd = "FzfLua",
	keys = {
		{
			"<leader>xx",
			"<cmd>FzfLua diagnostics_workspace<cr>",
			desc = "Workspace diagnostics",
		},
		{
			"<leader>xX",
			"<cmd>FzfLua diagnostics_document<cr>",
			desc = "Buffer diagnostics",
		},
		{
			"<leader>xq",
			diagnostics_to_quickfix,
			desc = "Diagnostics quickfix",
		},
		{
			"<leader>xL",
			diagnostics_to_loclist,
			desc = "Diagnostics location list",
		},
		{
			"<leader>xs",
			"<cmd>FzfLua lsp_document_symbols<cr>",
			desc = "Document symbols",
		},
		{
			"<leader>xl",
			"<cmd>FzfLua lsp_finder<cr>",
			desc = "LSP definitions and references",
		},
		{
			"<leader>xca",
			"<cmd>FzfLua lsp_code_actions<cr>",
			mode = { "n", "x" },
			desc = "Code actions",
		},
		{
			"gra",
			"<cmd>FzfLua lsp_code_actions<cr>",
			mode = { "n", "x" },
			desc = "Code actions",
		},
	},
	init = function()
		vim.diagnostic.config({
			severity_sort = true,
			update_in_insert = false,
			underline = true,
			signs = { text = diagnostic_icons },
			virtual_text = {
				spacing = 2,
				source = "if_many",
				prefix = "●",
			},
			float = {
				border = "rounded",
				header = "",
				prefix = "",
				source = "if_many",
			},
			jump = { wrap = true },
		})
	end,
	opts = {
		winopts = {
			height = 0.85,
			width = 0.90,
			preview = {
				layout = "horizontal",
				horizontal = "right:55%",
			},
		},
		fzf_opts = {
			["--layout"] = "reverse",
			["--info"] = "inline-right",
		},
		diagnostics = {
			cwd_only = false,
			file_icons = true,
			diag_icons = true,
			color_headings = true,
		},
		lsp = {
			cwd_only = false,
			code_actions = {
				previewer = "codeaction_native",
			},
		},
	},
	config = function(_, opts)
		local fzf = require("fzf-lua")
		fzf.setup(opts)
		fzf.register_ui_select()
	end,
}
