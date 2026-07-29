return {
	"dnlhc/glance.nvim",
	event = "LspAttach",
	cmd = "Glance",
	opts = {
		height = 18,
		zindex = 45,

		-- Keep the current buffer visible behind the preview when supported.
		preserve_win_context = true,

		-- Use a floating preview in narrow windows so the list stays usable.
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
			width = 0.33,
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

		-- Keep the existing definition/reference workflow, but add Glance's
		-- navigable preview and context window.
		vim.keymap.set("n", "gd", "<cmd>Glance definitions<cr>", { desc = "Glance definitions" })
		vim.keymap.set("n", "gr", "<cmd>Glance references<cr>", { desc = "Glance references" })
		vim.keymap.set("n", "gy", "<cmd>Glance type_definitions<cr>", { desc = "Glance type definitions" })
		vim.keymap.set("n", "gi", "<cmd>Glance implementations<cr>", { desc = "Glance implementations" })
	end,
}
