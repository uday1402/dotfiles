-- Supermaven Status Indicator
local function supermaven_status()
	local ok, api = pcall(require, "supermaven-nvim.api")

	if not ok then
		return "󰚩 SM OFF"
	end

	if api.is_running() then
		return "󰚩 SM ON"
	else
		return "󰚩 SM OFF"
	end
end

local daily_line_counter = require("config.daily_line_counter")

return {
	{
		"nvim-lualine/lualine.nvim",

		event = "VeryLazy",

		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},

		opts = {
			options = {
				theme = "auto",
				globalstatus = true,
				section_separators = "",
				component_separators = "│",
			},

			sections = {
				lualine_a = { "mode" },

				lualine_b = {
					"branch",
					"diff",
					"diagnostics",
				},

				lualine_c = {
					{ "filename", path = 1 },
				},

				lualine_x = {
					daily_line_counter.status,
					supermaven_status,
					"encoding",
					"fileformat",
					"filetype",
				},

				lualine_y = { "progress" },

				lualine_z = { "location" },
			},
		},
	},
}
