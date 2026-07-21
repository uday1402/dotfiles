-- useful for command line completions
return {
	"gelguy/wilder.nvim",

	dependencies = {
		"romgrk/fzy-lua-native",
	},

	build = ":UpdateRemotePlugins",

	config = function()
		local wilder = require("wilder")

		wilder.setup({
			modes = { ":", "/", "?" },
		})

		wilder.set_option(
			"renderer",
			wilder.popupmenu_renderer({
				highlighter = wilder.basic_highlighter(),
			})
		)
	end,
}
