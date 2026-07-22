return {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "FzfLua",
    keys = {
        {
            "<leader>xs",
            "<cmd>FzfLua lsp_document_symbols<cr>",
            desc = "Document symbols",
        },
        {
            "<leader>xl",
            "<cmd>FzfLua lsp_finder<cr>",
            desc = "LSP definitions and references",
        },
        {
            "<leader>xca",
            "<cmd>FzfLua lsp_code_actions<cr>",
            mode = { "n", "x" },
            desc = "Code actions",
        },
        {
            "gra",
            "<cmd>FzfLua lsp_code_actions<cr>",
            mode = { "n", "x" },
            desc = "Code actions",
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
