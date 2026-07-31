-- Mason installs LSP server binaries; nvim-lspconfig provides their defaults.
local servers = { "pyright", "clangd", "lua_ls" }

return {
	{
		"mason-org/mason.nvim",
		opts = {},
	},
	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = {
			"mason-org/mason.nvim",
			"neovim/nvim-lspconfig",
			"saghen/blink.cmp",
		},
		opts = {
			ensure_installed = servers,
			-- Mason v2 enables every installed server by default. Limit activation
			-- to the servers configured below.
			automatic_enable = servers,
		},
		config = function(_, opts)
			-- Apply user overrides before mason-lspconfig enables the servers.
			for _, server in ipairs(servers) do
				vim.lsp.config(server, require("config.lsp." .. server))
			end

			require("mason-lspconfig").setup(opts)

			-- Nvim 0.12+ ships :lsp, so nvim-lspconfig skips defining :LspInfo.
			-- Keep the old command as an alias to the built-in health check.
			if vim.fn.exists(":LspInfo") == 0 then
				vim.api.nvim_create_user_command("LspInfo", "checkhealth vim.lsp", {
					desc = "Show LSP status (alias to :checkhealth vim.lsp)",
				})
			end
		end,
	},
	{
		"jay-babu/mason-nvim-dap.nvim",
		dependencies = {
			"mason-org/mason.nvim",
			"mfussenegger/nvim-dap",
		},
		opts = {
			ensure_installed = { "codelldb" },
		},
	},
}
