-- responsible for running completions
return {
    "saghen/blink.cmp",

    version = "*",

    dependencies = {
        "rafamadriz/friendly-snippets",
    },

    opts = {
        keymap = {
            preset = "none",
            ["<K>"] = { "show", "show_documentation", "hide_documentation" },

            ["<C-e>"] = { "hide" },  -- ctrl e hides the box

            ["<Up>"] = { "select_prev", "fallback" },
            ["<Down>"] = { "select_next", "fallback" },

            ["<C-p>"] = { "select_prev", "fallback" },
            ["<C-n>"] = { "select_next", "fallback" },

            ["<CR>"] = { "accept", "fallback" },
        },

        appearance = {
            nerd_font_variant = "mono",
        },

        completion = {
            documentation = {
                auto_show = false,
                auto_show_delay_ms = 200,
            },
        },

        -- automatic signature help popup while typing function arguments
        signature = {
            enabled = true,
            window = {
                border = "rounded",
                show_documentation = true,
            },
        },

        sources = {
            default = {
                "lsp",
                "path",
                "snippets",
                "buffer",
            },

            -- explicit provider wiring (connects LSP servers to blink)
            providers = {
                lsp = {
                    name = "LSP",
                    module = "blink.cmp.sources.lsp",
                    fallbacks = { "buffer" },
                },
                path = {
                    name = "Path",
                    module = "blink.cmp.sources.path",
                    score_offset = 3,
                    fallbacks = { "buffer" },
                },
                snippets = {
                    name = "Snippets",
                    module = "blink.cmp.sources.snippets",
                    score_offset = -1,
                },
                buffer = {
                    name = "Buffer",
                    module = "blink.cmp.sources.buffer",
                },
            },
        },

        fuzzy = {
            implementation = "prefer_rust_with_warning",
        },
    },
}
