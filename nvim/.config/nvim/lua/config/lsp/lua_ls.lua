-- lua_ls: Lua LSP (for editing neovim config). Defaults come from nvim-lspconfig.
return {
    capabilities = require("blink.cmp").get_lsp_capabilities(),
    settings = {
        Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
        },
    },
}
