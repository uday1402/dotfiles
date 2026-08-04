return {
	"barrett-ruth/live-server.nvim",
	cmd = { "LiveServerStart", "LiveServerStop", "LiveServerToggle" },
	keys = {
		{ "<leader>tl", "<cmd>LiveServerToggle<cr>", desc = "Toggle live server" },
	},
	init = function()
		-- Keep this aligned with the browser DAP launch URL.
		vim.g.live_server = {
			port = 8080,
			browser = true,
		}
	end,
}
