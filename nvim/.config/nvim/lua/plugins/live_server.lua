-- ============================================================================
-- Plugin: live-server.nvim
-- Purpose: Lightweight local development HTTP server with live reloading for
--          HTML, CSS, and client-side JavaScript.
--
-- Keymaps:
--   <leader>tl      (n) - Toggle live server (start if stopped, stop if running)
--
-- Commands:
--   :LiveServerStart    - Start the live reload server and launch browser
--   :LiveServerStop     - Stop the active live reload server
--   :LiveServerToggle   - Toggle the server on or off
-- ============================================================================

return {
	"https://forge.barrettruth.com/barrettruth/live-server.nvim",
	cmd = { "LiveServerStart", "LiveServerStop", "LiveServerToggle" },
	keys = {
		{ "<leader>tl", "<cmd>LiveServerToggle<cr>", desc = "Toggle live server" },
	},
	init = function()
		-- Global live server runtime configuration.
		-- Port 8080 aligns with browser DAP launch configurations.
		vim.g.live_server = {
			port = 8080,
			browser = true, -- Automatically launch default browser on start
		}
	end,
}
