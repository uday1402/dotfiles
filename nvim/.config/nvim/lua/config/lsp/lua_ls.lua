-- lua_ls: Lua LSP (for editing neovim config). Defaults come from nvim-lspconfig.

---@type vim.lsp.Config
local config = {
	---@type lspconfig.settings.lua_ls
	settings = {
		Lua = {
			diagnostics = { globals = { "vim" } },
			workspace = { checkThirdParty = false },
			telemetry = { enable = false },
		},
	},
}

return config
