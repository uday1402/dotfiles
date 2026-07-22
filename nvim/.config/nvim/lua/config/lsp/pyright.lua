-- pyright: Python LSP. Defaults (cmd, filetypes, root_markers) come from nvim-lspconfig.

---@type vim.lsp.Config
local config = {
	capabilities = require("blink.cmp").get_lsp_capabilities(),
}

return config
