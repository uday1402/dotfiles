return {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "FzfLua",
    keys = {
        {
            "<leader>xs",
            "<cmd>FzfLua lsp_document_symbols<cr>",
            desc = "Document symbols",
            -- show symbols(functions, classes, variables, methods etc)  in the current file; Useful for jumping around a file quickly.
        },
        {
            "<leader>xl",
            "<cmd>FzfLua lsp_finder<cr>",
            desc = "LSP definitions and references",
            -- shows LSP locations related to the symbol under the cursor. Includes definitions, references, implementations, and declarations; let's you search where something is used or defined.
        },
        {
            "<leader>xca",
            "<cmd>FzfLua lsp_code_actions<cr>",
            mode = { "n", "x" },
            desc = "Code actions",
            silent = true,
            -- shows available code actions from the language server; Import fixes, quick refactors, rename suggestions, apply fix-its. Can be used over a region in visual mode.
        },
        {
            "gra",
            "<cmd>FzfLua lsp_code_actions<cr>",
            mode = { "n", "x" },
            desc = "Code actions",
            -- same as above, which helps in finding code actions(more vim style keymap)
        },
    },
    opts = {
        winopts = {
            height = 0.85,
            width = 0.90,
            preview = {
                layout = "horizontal",
                horizontal = "right:55%",
            },
        },
        fzf_opts = {
            ["--layout"] = "reverse",
            ["--info"] = "inline-right",
        },
        lsp = {
            cwd_only = false,
            code_actions = {
                previewer = "codeaction_native",
            },
        },
    },
    config = function(_, opts)
        local fzf = require("fzf-lua")
        fzf.setup(opts)
        fzf.register_ui_select()
    end,
}
