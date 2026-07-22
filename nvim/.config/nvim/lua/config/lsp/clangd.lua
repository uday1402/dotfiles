-- clangd: C/C++ LSP. Defaults (cmd, filetypes, root_markers) come from nvim-lspconfig.

---@type vim.lsp.Config
local config = {
	capabilities = require("blink.cmp").get_lsp_capabilities(),
	---@param params lsp.InitializeParams
	before_init = function(params)
		-- clangd 22 deprecated this extension in favor of the standard LSP 3.17
		-- general.positionEncodings capability already advertised by Neovim.
		rawset(params.capabilities, "offsetEncoding", nil)
	end,
}

return config
