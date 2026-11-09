-- ============================================================================
-- Plugin: fzf-lua
-- Purpose: Fast and asynchronous fuzzy finder powered by fzf. In this setup,
--          it is primarily leveraged for deep LSP navigation, symbol jumping,
--          code actions, and as the global `vim.ui.select` replacement.
--
-- Keymaps:
--   <leader>xs       - Document symbols (jump to functions, classes, vars in file)
--   <leader>xl       - LSP finder (combined definitions, references, implementations)
--   <leader>xca, gra - LSP code actions (Normal & Visual: fixes, imports, refactors)
--
-- Commands:
--   :FzfLua <builtin> - Run any fzf-lua builtin picker (e.g., :FzfLua files)
-- ============================================================================

return {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "FzfLua",
    init = function()
        -- Lazy register vim.ui.select so any dialog requiring UI select loads fzf-lua seamlessly
        vim.ui.select = function(...)
            require("fzf-lua").register_ui_select()
            return vim.ui.select(...)
        end
    end,
    keys = {
        {
            "<leader>xs",
            "<cmd>FzfLua lsp_document_symbols<cr>",
            desc = "LSP: Document symbols",
            -- Quickly find and jump to functions, classes, methods, and variables in the current buffer
        },
        {
            "<leader>xl",
            "<cmd>FzfLua lsp_finder<cr>",
            desc = "LSP: Finder (defs, refs, impls)",
            -- Combined view showing where the symbol under cursor is defined, implemented, and referenced
        },
        {
            "<leader>xca",
            "<cmd>FzfLua lsp_code_actions<cr>",
            mode = { "n", "x" },
            desc = "LSP: Code actions",
            silent = true,
            -- Quickfixes, refactors, and import suggestions; works over visual selections as well
        },
        {
            "gra",
            "<cmd>FzfLua lsp_code_actions<cr>",
            mode = { "n", "x" },
            desc = "LSP: Code actions (gra)",
            -- Standard Neovim 0.10+ style mapping for code actions
        },
    },
    opts = {
        winopts = {
            height = 0.85,
            width = 0.90,
            backdrop = false, -- Keep background transparent/un-dimmed
            preview = {
                layout = "horizontal",
                horizontal = "right:55%", -- Preview pane on the right taking 55% of window
            },
        },
        fzf_opts = {
            ["--layout"] = "reverse",
            ["--info"] = "inline-right",
        },
        lsp = {
            cwd_only = false,
            code_actions = {
                previewer = "codeaction_native", -- Rich diff preview for code actions before applying
            },
        },
    },
    config = function(_, opts)
        local fzf = require("fzf-lua")
        fzf.setup(opts)
        -- Route Neovim's built-in vim.ui.select dialogues through fzf-lua
        fzf.register_ui_select()
    end,
}
