-- ============================================================================
-- Plugin: nvim-treesitter
-- Purpose: Fast, syntax-tree-aware parsing library providing rich syntax
--          highlighting, AST-based indentation, and structural code queries.
--
-- Commands:
--   :TSInstall <lang>     - Install Treesitter grammar/parser for a language
--                           (e.g., `:TSInstall rust`, `:TSInstall python`).
--   :TSInstallInfo        - List all available parsers and their install status.
--   :TSUpdate [lang]      - Update installed Treesitter parser(s).
--   :TSUpdateSync         - Synchronously update all parsers (blocks UI).
--   :TSUninstall <lang>   - Remove an installed language parser.
--   :Inspect              - Show Treesitter capture group, semantic token, and
--                           highlight group for the code under the cursor.
--   :InspectTree          - Open an interactive sidebar displaying the syntax
--                           tree (AST) of the current buffer.
--   :EditQuery            - Open a live Treesitter query editor for the current
--                           buffer's language.
--
-- Features:
--   • Native Neovim 0.10+ parser activation via `vim.treesitter.start()`.
--   • AST-aware indentation using `nvim-treesitter.indentexpr()`.
--   • Background asynchronous verification and installation of core parsers.
--   • Auto-build hook running `:TSUpdate` whenever the plugin updates.
-- ============================================================================

return {
	"nvim-treesitter/nvim-treesitter",

	-- Automatically update installed parsers whenever nvim-treesitter updates
	build = ":TSUpdate",

	-- Lazy-load on buffer creation / read, or when a TS command is executed
	event = { "BufReadPost", "BufNewFile" },
	cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },

	init = function()
		-- FileType autocommand: activate syntax highlighting and smart indent
		-- for any buffer with an available Treesitter parser.
		--
		-- Note: In Neovim 0.10+ and the nvim-treesitter main branch, parser
		-- attachment is initiated directly through Neovim core's
		-- `vim.treesitter.start()` rather than the legacy `.configs` setup table.
		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("treesitter-start", { clear = true }),
			callback = function(args)
				-- Safely attempt to start treesitter for the active buffer;
				-- pcall prevents errors if a parser is missing for this filetype.
				local ok = pcall(vim.treesitter.start, args.buf)
				if ok then
					-- Set buffer-local indentation expression to Treesitter AST indent
					vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end
			end,
		})
	end,

	config = function()
		require("nvim-treesitter").setup()

		-- Install or verify core parsers asynchronously in the background.
		-- Using `vim.schedule` ensures Neovim finishes drawing the editor UI
		-- immediately without being blocked by parser compilation or disk I/O.
		vim.schedule(function()
			local ok, ts = pcall(require, "nvim-treesitter")
			if ok and ts.install then
				ts.install({
					-- Neovim & Editor configuration
					"lua",
					"vim",
					"vimdoc",

					-- Systems & General Purpose
					"python",
					"c",
					"cpp",

					-- Shell, Regex & Query languages
					"bash",
					"markdown",
					"markdown_inline",
					"regex",
					"query",

					-- Structured data & Config formats
					"json",
					"json5",
					"yaml",
					"toml",

					-- Web Development (HTML / CSS / JS / TS)
					"html",
					"css",
					"scss",
					"javascript",
					"typescript",
					"tsx",
					"jsdoc",

					-- Database, Containerization & Git
					"sql",
					"dockerfile",
					"git_config",
					"git_rebase",
					"gitattributes",
					"gitcommit",
					"gitignore",
				})
			end
		end)
	end,
}
