return {
	"windwp/nvim-ts-autotag",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	ft = {
		"html",
		"markdown",
		"javascript",
		"javascriptreact",
		"javascript.jsx",
		"typescript",
		"typescriptreact",
		"typescript.tsx",
		"vue",
		"htmlangular",
		"svelte",
		"templ",
		"handlebars",
		"hbs",
	},
	opts = {
		opts = {
			enable_close = true,
			enable_rename = true,
			enable_close_on_slash = false,
		},
		-- nvim-ts-autotag's built-in aliases cover these filetypes; keeping the
		-- explicit aliases here makes JSX/TSX/template support intentional.
		aliases = {
			javascript = "typescriptreact",
			typescript = "typescriptreact",
			javascriptreact = "typescriptreact",
			vue = "html",
			htmlangular = "html",
			markdown = "html",
		},
	},
}
