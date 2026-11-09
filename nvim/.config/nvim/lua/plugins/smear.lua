-- ============================================================================
-- Plugin: smear-cursor.nvim
-- Purpose: Smooth animated cursor trail/smear effect inspired by Neovide.
--
-- How to Use:
--   <leader>ts        - Toggle smear animation on / off (:SmearCursorToggle)
--   Status: Disabled by default on startup; toggle whenever desired.
-- ============================================================================

return {
	{
		"sphamba/smear-cursor.nvim",

		cmd = { "SmearCursorToggle" },
		keys = {
			{ "<leader>ts", "<cmd>SmearCursorToggle<cr>", desc = "Toggle Smear Cursor" },
		},

		opts = {
			-- Initial state: keep disabled until toggled by user command / keymap
			enabled = false,

			-- --------------------------------------------------------------------
			-- Animation Timing & Physics (Normal Mode)
			-- --------------------------------------------------------------------

			-- How fast the head of the smear moves towards the target (0 = stationary, 1 = instant).
			stiffness = 0.8,

			-- How fast the trailing tail catches up to the head (lower = longer smear trail).
			trailing_stiffness = 0.5,

			-- Velocity reduction over time (0 = no friction/overshoot, 1 = immediate stop).
			damping = 0.65,

			-- --------------------------------------------------------------------
			-- Animation Timing & Physics (Insert Mode)
			-- --------------------------------------------------------------------

			-- Head stiffness specifically while typing in Insert mode.
			stiffness_insert_mode = 0.7,

			-- Tail stiffness in Insert mode (higher value keeps the trail short while typing).
			trailing_stiffness_insert_mode = 0.7,

			-- Velocity damping / friction while in Insert mode.
			damping_insert_mode = 0.7,

			-- --------------------------------------------------------------------
			-- Distance & Trigger Thresholds
			-- --------------------------------------------------------------------

			-- Stop animation when the tail is within this distance (in characters) from the target.
			distance_stop_animating = 0.5,

			-- Smear cursor even when moving to adjacent neighbor lines (e.g., standard j/k motions).
			smear_between_neighbor_lines = true,

			-- --------------------------------------------------------------------
			-- Visual Appearance & Rendering
			-- --------------------------------------------------------------------

			-- Custom hex color for the smear trail (Catppuccin Rosewater tint).
			cursor_color = "#f5e0dc",

			-- Gamma correction exponent used for color blending gradients (1.0 = linear blend).
			gamma = 1,

			-- Workaround to hide real terminal cursor by drawing underneath it (unneeded with termguicolors).
			hide_target_hack = false,

			-- Set to true if font supports Unicode 13 Legacy Computing blocks for smoother sub-cell trails.
			legacy_computing_symbols_support = false,

			-- --------------------------------------------------------------------
			-- Performance
			-- --------------------------------------------------------------------

			-- Timer interval between animation frames in milliseconds (17 ms ≈ 60 FPS).
			time_interval = 17,
		},

		config = function(_, opts)
			require("smear_cursor").setup(opts)
		end,
	},
}
