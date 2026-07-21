-- pyright: Python LSP. Defaults (cmd, filetypes, root_markers) come from nvim-lspconfig.
return {
    capabilities = require("blink.cmp").get_lsp_capabilities(),
}
