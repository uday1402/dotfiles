-- Keep only the server-selected overload in signature help. Blink otherwise
-- renders every label returned by Pyright, which can look like duplicate
-- signatures for overloaded functions.
local function use_active_signature(source, context, callback)
    return source:get_signature_help(context, function(signature_help)
        if not signature_help or #signature_help.signatures <= 1 then
            callback(signature_help)
            return
        end

        local active_index = (signature_help.activeSignature or 0) + 1
        local active_signature = signature_help.signatures[active_index] or signature_help.signatures[1]

        signature_help.signatures = { active_signature }
        signature_help.activeSignature = 0
        callback(signature_help)
    end)
end

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
                -- Pyright documentation can repeat the signature label. Keep the
                -- concise signature and avoid rendering the same details twice.
                show_documentation = false,
            },
        },

        sources = {
            default = {
                "lsp",
                "path",
                "snippets",
                "buffer",
            },

            -- Keep the normal LSP/path/snippet/buffer providers everywhere;
            -- Dadbod is an additional source only for database buffers.
            per_filetype = {
                sql = { "dadbod", inherit_defaults = true },
                mysql = { "dadbod", inherit_defaults = true },
                plsql = { "dadbod", inherit_defaults = true },
            },

            -- explicit provider wiring (connects LSP servers to blink)
            providers = {
                lsp = {
                    name = "LSP",
                    module = "blink.cmp.sources.lsp",
                    fallbacks = { "buffer" },
                    override = {
                        get_signature_help = use_active_signature,
                    },
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
                dadbod = {
                    name = "Dadbod",
                    module = "vim_dadbod_completion.blink",
                },
            },
        },

        fuzzy = {
            implementation = "prefer_rust_with_warning",
        },
    },
}
