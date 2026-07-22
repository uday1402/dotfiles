-- lua_ls: Lua LSP (for editing neovim config). Defaults come from nvim-lspconfig.

---@type vim.lsp.Config
local config = {
	capabilities = require("blink.cmp").get_lsp_capabilities(),
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
