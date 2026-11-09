-- ============================================================================
-- Plugin: nvim-ts-autotag
-- Purpose: Uses Tree-sitter to automatically close and rename HTML, XML, and JSX
--          tags in real time as you type.
--
-- Features / Automatic Behavior:
--   Auto-close   - Typing '>' on an opening tag (e.g., `<div>`) automatically
--                  inserts the matching closing tag `</div>` with cursor inside.
--   Auto-rename  - Editing an opening tag name automatically synchronizes and
--                  renames the closing tag in real time (and vice versa).
--
-- Supported Filetypes:
--   HTML, XML, JSX/TSX (React), Vue, Svelte, Angular, Markdown, Templ, Handlebars.
-- ============================================================================

return {
	"windwp/nvim-ts-autotag",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	-- Lazy-load autotag only on relevant web / template filetypes
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
			-- Automatically close opening tags upon typing `>`
			enable_close = true,
			-- Automatically rename pairs when either opening or closing tag is edited
			enable_rename = true,
			-- Disable slash auto-closing (`</`) to avoid conflicts with snippets/autopairs
			enable_close_on_slash = false,
		},
		-- Map filetypes to tree-sitter dialect parsers.
		-- nvim-ts-autotag has built-in aliases, but explicit aliases ensure
		-- robust JSX/TSX and template grammar resolution.
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
