-- ============================================================================
-- Plugin: glance.nvim
-- Purpose: VS Code-style inline peek window for LSP definitions, references,
--          type definitions, and implementations without losing buffer context.
--
-- LSP Keymaps:
--   gd           - Peek / jump to definitions
--   gr           - Peek / jump to references
--   gy           - Peek / jump to type definitions
--   gi           - Peek / jump to implementations
--
-- Controls Inside Glance Window:
--   j / k        - Navigate up/down list of results
--   <Tab> / <S-Tab> - Jump to next / previous location
--   <C-u> / <C-d>   - Scroll preview pane up / down (5 lines)
--   <CR>         - Jump to target in current window & close Glance
--   v            - Jump to target in a vertical split
--   s            - Jump to target in a horizontal split
--   t            - Jump to target in a new tab
--   q / <Esc>    - Close Glance peek window
-- ============================================================================

return {
	"dnlhc/glance.nvim",
	cmd = "Glance",
	keys = {
		{ "gd", "<cmd>Glance definitions<cr>", desc = "Glance definitions" },
		{ "gr", "<cmd>Glance references<cr>", desc = "Glance references" },
		{ "gy", "<cmd>Glance type_definitions<cr>", desc = "Glance type definitions" },
		{ "gi", "<cmd>Glance implementations<cr>", desc = "Glance implementations" },
	},
	opts = {
		height = 18,
		zindex = 45,

		-- Keep the current buffer visible behind the preview when supported
		preserve_win_context = true,

		-- Float the preview if current window is narrow (<100 cols) to avoid cramped layouts
		detached = function(winid)
			return vim.api.nvim_win_get_width(winid) < 100
		end,

		preview_win_opts = {
			cursorline = true,
			number = true,
			wrap = true,
		},

		border = {
			enable = true,
			top_char = "―",
			bottom_char = "―",
		},

		list = {
			position = "right",
			width = 0.33, -- Results list occupies right 33%; preview gets 67%
		},

		theme = {
			enable = true,
			mode = "auto",
		},

		folds = {
			fold_closed = "",
			fold_open = "",
			folded = true,
		},

		indent_lines = {
			enable = true,
			icon = "│",
		},

		winbar = {
			enable = true,
		},
	},
	config = function(_, opts)
		local glance = require("glance")
		local actions = glance.actions

		opts.mappings = {
			list = {
				["j"] = actions.next,
				["k"] = actions.previous,
				["<Tab>"] = actions.next_location,
				["<S-Tab>"] = actions.previous_location,
				["<C-u>"] = actions.preview_scroll_win(5),
				["<C-d>"] = actions.preview_scroll_win(-5),
				["v"] = actions.jump_vsplit,
				["s"] = actions.jump_split,
				["t"] = actions.jump_tab,
				["<CR>"] = actions.jump,
				["q"] = actions.close,
				["<Esc>"] = actions.close,
			},
			preview = {
				["<Tab>"] = actions.next_location,
				["<S-Tab>"] = actions.previous_location,
				["q"] = actions.close,
				["<Esc>"] = actions.close,
			},
		}

		glance.setup(opts)

		-- LSP Navigation Mappings using Glance's interactive peek window
		vim.keymap.set("n", "gd", "<cmd>Glance definitions<cr>", { desc = "Glance definitions" })
		vim.keymap.set("n", "gr", "<cmd>Glance references<cr>", { desc = "Glance references" })
		vim.keymap.set("n", "gy", "<cmd>Glance type_definitions<cr>", { desc = "Glance type definitions" })
		vim.keymap.set("n", "gi", "<cmd>Glance implementations<cr>", { desc = "Glance implementations" })
	end,
}
