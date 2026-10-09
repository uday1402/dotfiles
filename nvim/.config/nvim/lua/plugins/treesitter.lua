-- nvim-treesitter: installs parsers and provides treesitter queries
-- (main branch API: highlighting via vim.treesitter.start(), no more .configs module)
return {
    "nvim-treesitter/nvim-treesitter",

    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },

    init = function()
        -- enable treesitter highlight + indent per filetype
        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("treesitter-start", { clear = true }),
            callback = function(args)
                -- Only start treesitter if the plugin has been loaded and parser is available
                -- lazy.nvim will load the plugin before the autocmd runs due to the event triggers
                local ok = pcall(vim.treesitter.start, args.buf)
                if ok then
                    vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end
            end,
        })
    end,

    config = function()
        require("nvim-treesitter").setup()

        -- install parsers (async, no-op if already installed)
        require("nvim-treesitter").install({
            "lua", "vim", "vimdoc",

            "python", "c", "cpp",

            "bash", "markdown", "markdown_inline", "regex", "query",
            "json", "json5", "yaml", "toml",

            "html", "css", "scss", "javascript", "typescript", "tsx", "jsdoc",

            "sql", "dockerfile",
            "git_config", "git_rebase", "gitattributes", "gitcommit", "gitignore",
        })
    end,
}
