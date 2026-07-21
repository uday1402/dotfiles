-- mason installs LSP server binaries; server configs live in lsp/*.lua
return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = {
			"williamboman/mason.nvim",
			"neovim/nvim-lspconfig",
			"saghen/blink.cmp",
		},
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = { "pyright", "clangd", "lua_ls" },
				automatic_installation = true,
			})

			-- load server configs from lua/config/lsp/*.lua
			vim.lsp.config("pyright", require("config.lsp.pyright"))
			vim.lsp.config("clangd", require("config.lsp.clangd"))
			vim.lsp.config("lua_ls", require("config.lsp.lua_ls"))

			vim.lsp.enable({ "pyright", "clangd", "lua_ls" })

			-- Nvim 0.12+ ships :lsp, so nvim-lspconfig skips defining :LspInfo.
			-- Keep the old command as an alias to the built-in health check.
			vim.api.nvim_create_user_command("LspInfo", "checkhealth vim.lsp", {
				desc = "Show LSP status (alias to :checkhealth vim.lsp)",
			})
		end,
	},
}
