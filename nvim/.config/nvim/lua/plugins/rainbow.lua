return {
	"HiPhish/rainbow-delimiters.nvim",

	config = function()
		local defaults = require("rainbow-delimiters.default")

		require("rainbow-delimiters.setup").setup({
			-- This is the plugin's effective default. Making it explicit keeps
			-- :checkhealth from treating an otherwise empty report as an error.
			priority = {
				[""] = defaults.priority[""],
			},
		})
	end,
}
