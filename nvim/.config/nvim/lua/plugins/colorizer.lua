-- ============================================================================
-- Plugin: nvim-colorizer.lua
-- Purpose: High-performance real-time color highlighter for CSS, web files,
--          and Tailwind CSS classes.
--
-- Supported Color Formats:
--   • Hex codes (#rgb, #rrggbb, #rrggbbaa)
--   • CSS color functions (rgb(), rgba(), hsl(), hsla(), hwb(), oklch())
--   • Tailwind CSS color classes (e.g., bg-blue-500, text-emerald-400)
--
-- Commands:
--   :ColorizerToggle           - Toggle colorizer highlights in the current buffer
--   :ColorizerAttachToBuffer   - Enable colorizer for current buffer
--   :ColorizerDetachFromBuffer - Disable colorizer for current buffer
--   :ColorizerReloadAllBuffers - Force refresh color highlights across all buffers
-- ============================================================================

return {
	"catgoose/nvim-colorizer.lua",

	-- Lazy-load on web development and frontend filetypes
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
				-- Disable named colors (e.g. "blue", "gray") so standard English words
				-- in variables, comments, and strings are not accidentally highlighted.
				names = { enable = false },

				-- Hex colors (#RGB, #RRGGBB, and #RRGGBBAA with alpha channel)
				hex = {
					default = true,
					rrggbbaa = true,
				},

				-- Standard & modern CSS color functions
				rgb = { enable = true },
				hsl = { enable = true },
				hwb = { enable = true },
				oklch = { enable = true },
				css_fn = true,

				-- Highlight Tailwind CSS color utility classes (e.g., bg-red-500)
				tailwind = { enable = true },
			},
		},
	},
}
