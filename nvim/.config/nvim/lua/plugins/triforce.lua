-- this is a tool used to track the lines of code and the time I spend coding in neovim
return {
	{
		"gisketch/triforce.nvim",
		dependencies = { "nvzone/volt" },
		lazy = false,
		init = function()
			require("config.daily_line_counter").setup()
		end,
		opts = {
			keymap = { show_profile = nil },
			notifications = {
				enabled = false,
				level_up = false,
				achievements = false,
			},
		},
		keys = {
			{
				"<leader>tp",
				function()
					require("triforce").show_profile()
				end,
				desc = "Triforce Profile",
			},
		},
	},
}
