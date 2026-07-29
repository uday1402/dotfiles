return {
    "lewis6991/hover.nvim",
    event = "VeryLazy",
    opts = {
        -- LSP hover is the primary provider; the others make K useful for
        -- diagnostics, folded code, man pages, words, and highlight groups.
        providers = {
            "hover.providers.diagnostic",
            "hover.providers.lsp",
            "hover.providers.man",
            "hover.providers.dictionary",
            "hover.providers.fold_preview",
            "hover.providers.highlight",
        },
        preview_opts = {
            border = "rounded",
        },
        preview_window = false,
        title = true,
        mouse_providers = { "hover.providers.lsp" },
        mouse_delay = 1000,
    },
    config = function(_, opts)
        local hover = require("hover")

        hover.config(opts)

        -- Keep K as the familiar documentation key, but use hover.nvim's
        -- context-aware providers instead of only vim.lsp.buf.hover().
        vim.keymap.set("n", "K", hover.open, { desc = "Hover documentation" })
        vim.keymap.set("n", "gK", hover.select, { desc = "Select documentation source" })
        vim.keymap.set("n", "[K", function()
            hover.switch("previous")
        end, { desc = "Previous documentation source" })
        vim.keymap.set("n", "]K", function()
            hover.switch("next")
        end, { desc = "Next documentation source" })
    end,
}
