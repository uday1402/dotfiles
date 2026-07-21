return {
	{
		"sphamba/smear-cursor.nvim",

		event = "VeryLazy",

		opts = {
			-- Animation Timing
			stiffness = 0.8,

			trailing_stiffness = 0.5,

			stiffness_insert_mode = 0.7,

			trailing_stiffness_insert_mode = 0.7,

			damping = 0.65,

			damping_insert_mode = 0.7,

			-- Distance Behaviour
			distance_stop_animating = 0.5,

			-- Cursor Appearance
			smear_between_neighbor_lines = true,

			hide_target_hack = false,

			gamma = 1,

			-- Performance
			time_interval = 17,

			-- Legacy Algorithm
			legacy_computing_symbols_support = false,

			-- Subtle Black Theme Style
			cursor_color = "#f5e0dc",
			normal_bg = "#000000",
		},

		config = function(_, opts)
			require("smear_cursor").setup(opts)

			-- Optional Toggle Keymap
			vim.keymap.set("n", "<leader>ts", ":SmearCursorToggle<CR>", {
				desc = "Toggle Smear Cursor",
				silent = true,
			})
		end,
	},
}
