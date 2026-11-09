-- ============================================================================
-- Plugin: hover.nvim
-- Purpose: Context-aware hover documentation popup extending Neovim's built-in
--          `vim.lsp.buf.hover()` with multi-provider fallbacks (LSP, DAP,
--          Diagnostics, and Man pages).
--
-- Keymaps:
--   K               - Open hover popup at cursor. If already open, pressing K
--                     a second time focuses inside the popup window to scroll or copy.
--   q / <Esc>       - Close hover popup when focused inside it.
--   gK              - Interactively select documentation source (if multiple available).
--   [K / ]K         - Switch to previous / next documentation source.
--
-- Providers (in priority order):
--   1. LSP          - Function signatures, types, and docstrings (primary)
--   2. DAP          - Variable value evaluation while paused in a debug session
--   3. Diagnostic   - Error / warning details when no LSP doc is available
--   4. Man          - Unix manual pages for C / shell system calls
-- ============================================================================

return {
    "lewis6991/hover.nvim",
    keys = {
        {
            "K",
            function()
                local hover = require("hover")
                local bufnr = vim.api.nvim_get_current_buf()
                local hover_win = vim.b[bufnr].hover_preview
                if hover_win and vim.api.nvim_win_is_valid(hover_win) then
                    hover.enter()
                else
                    hover.open()
                    vim.schedule(function()
                        local win = vim.b[bufnr].hover_preview
                        if win and vim.api.nvim_win_is_valid(win) then
                            vim.wo[win].winhighlight = "Normal:HoverWindow,NormalFloat:HoverWindow,FloatBorder:HoverBorder,FloatTitle:FloatTitle"
                        end
                    end)
                end
            end,
            desc = "Hover: Open / focus documentation",
        },
        {
            "gK",
            function()
                require("hover").select()
            end,
            desc = "Hover: Select documentation source",
        },
        {
            "[K",
            function()
                require("hover").switch("previous")
            end,
            desc = "Hover: Previous source",
        },
        {
            "]K",
            function()
                require("hover").switch("next")
            end,
            desc = "Hover: Next source",
        },
    },
    opts = {
        providers = {
            "hover.providers.lsp",
            "hover.providers.dap",
            "hover.providers.diagnostic",
            "hover.providers.man",
        },
        preview_opts = {
            border = "rounded",
            max_width = 80,
            max_height = 20,
            focusable = true,
        },
        preview_window = false,
        title = false, -- Disable cluttered provider winbar tab header
    },
    config = function(_, opts)
        local hover = require("hover")

        hover.config(opts)

        -- Synchronize hover window highlights with the active colorscheme
        local function sync_hover_highlights()
            local border_hl = vim.api.nvim_get_hl(0, { name = "FloatBorder", link = false })
            local float_hl = vim.api.nvim_get_hl(0, { name = "NormalFloat", link = false })

            vim.api.nvim_set_hl(0, "HoverBorder", {
                fg = border_hl.fg,
                bg = "NONE",
            })
            vim.api.nvim_set_hl(0, "HoverWindow", {
                fg = float_hl.fg,
                bg = "NONE",
            })
        end

        sync_hover_highlights()

        -- Re-apply highlights whenever the user switches colorschemes
        vim.api.nvim_create_autocmd("ColorScheme", {
            callback = sync_hover_highlights,
        })

        -- Close hover window with <Esc> or q when focused inside it
        vim.api.nvim_create_autocmd("WinEnter", {
            callback = function()
                if vim.w[0].hover_preview then
                    vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = 0, silent = true, nowait = true })
                end
            end,
        })

        -- Press K to open hover documentation. If already open, pressing K a
        -- second time focuses inside the popup window to scroll or copy text.
        vim.keymap.set("n", "K", function()
            local bufnr = vim.api.nvim_get_current_buf()
            local hover_win = vim.b[bufnr].hover_preview
            if hover_win and vim.api.nvim_win_is_valid(hover_win) then
                hover.enter()
            else
                hover.open()
                -- Enforce matching theme winhighlight on the newly created popup
                vim.schedule(function()
                    local win = vim.b[bufnr].hover_preview
                    if win and vim.api.nvim_win_is_valid(win) then
                        vim.wo[win].winhighlight = "Normal:HoverWindow,NormalFloat:HoverWindow,FloatBorder:HoverBorder,FloatTitle:FloatTitle"
                    end
                end)
            end
        end, { desc = "Hover: Open / focus documentation" })

        -- Interactive selector & cycling when multiple sources are available
        vim.keymap.set("n", "gK", hover.select, { desc = "Hover: Select documentation source" })
        vim.keymap.set("n", "[K", function()
            hover.switch("previous")
        end, { desc = "Hover: Previous source" })
        vim.keymap.set("n", "]K", function()
            hover.switch("next")
        end, { desc = "Hover: Next source" })
    end,
}
