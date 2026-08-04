return {
	"catgoose/nvim-colorizer.lua",
	ft = {
		"css",
		"scss",
		"less",
		"html",
		"javascriptreact",
		"typescriptreact",
		"javascript",
		"typescript",
		"vue",
		"svelte",
	},
	opts = {
		filetypes = {
			"css",
			"scss",
			"less",
			"html",
			"javascriptreact",
			"typescriptreact",
			"javascript",
			"typescript",
			"vue",
			"svelte",
		},
		options = {
			parsers = {
				-- Keep colorization focused on literal CSS colors/functions and
				-- Tailwind tokens; arbitrary prose/named words stay untouched.
				names = { enable = false },
				hex = {
					default = true,
					rrggbbaa = true,
				},
				rgb = { enable = true },
				hsl = { enable = true },
				hwb = { enable = true },
				oklch = { enable = true },
				css_fn = true,
				tailwind = { enable = true },
			},
		},
	},
}
