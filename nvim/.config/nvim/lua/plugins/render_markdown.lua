-- ============================================================================
-- Plugin: render-markdown.nvim
-- Purpose: In-buffer rich visual rendering for Markdown documents, inline math,
--          tables, checkboxes, callout boxes, and CodeCompanion AI chats.
--
-- Commands:
--   :RenderMarkdown toggle    - Toggle markdown rendering on / off in current buffer.
--   :RenderMarkdown enable    - Turn on rich rendering for the active buffer.
--   :RenderMarkdown disable   - Turn off rich rendering for the active buffer.
--   :RenderMarkdown expand    - Expand all collapsed/hidden markdown sections.
--   :RenderMarkdown contract  - Contract / collapse all markdown sections.
--   :RenderMarkdown log       - Open the render-markdown debug log window.
--
-- Keymaps (registered under <leader>m prefix in KEYMAPS.md / which-key):
--   <leader>mr       - Toggle markdown rendering on / off (:RenderMarkdown toggle)
--   <leader>me       - Expand all sections (:RenderMarkdown expand)
--   <leader>mc       - Contract all sections (:RenderMarkdown contract)
--   <leader>ml       - Open debug log (:RenderMarkdown log)
--
-- Features:
--   • Visual level-specific heading icons and background highlights.
--   • Unicode bullet symbols (●, ○, ◆, ◇) replacing raw asterisks/hyphens.
--   • Interactive/rendered checkbox states (checked / unchecked icons).
--   • Box-drawn borders for code blocks with language icon and syntax styling.
--   • Clean box-drawing border characters for pipe tables.
--   • Concealed raw Markdown syntax markers with custom conceallevel in normal mode.
--   • Seamless integration with CodeCompanion AI chat buffers.
--   • Exemption for transient floating scratch windows (buftype=nofile).
-- ============================================================================

return {
	"MeanderingProgrammer/render-markdown.nvim",

	dependencies = {
		"nvim-treesitter/nvim-treesitter", -- Required for AST node parsing
		"nvim-tree/nvim-web-devicons", -- Required for code block & link icons
	},

	-- Load only when viewing Markdown files or CodeCompanion AI chat buffers
	ft = { "markdown", "codecompanion" },

	keys = {
		{
			"<leader>mr",
			"<cmd>RenderMarkdown toggle<cr>",
			desc = "Markdown: Toggle render",
		},
		{
			"<leader>me",
			"<cmd>RenderMarkdown expand<cr>",
			desc = "Markdown: Expand all sections",
		},
		{
			"<leader>mc",
			"<cmd>RenderMarkdown contract<cr>",
			desc = "Markdown: Contract all sections",
		},
		{
			"<leader>ml",
			"<cmd>RenderMarkdown log<cr>",
			desc = "Markdown: Open debug log",
		},
	},
	-- },

	opts = {
		-- Render in both active markdown documents and CodeCompanion chat buffers
		file_types = { "markdown", "codecompanion" },

		-- Headings: Render custom level icons (H1 - H6) with background highlights
		heading = {
			enabled = true,
			sign = true,
			icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
		},

		-- Bullet lists: Replace raw markdown dashes/asterisks with hierarchical bullets
		bullet = {
			enabled = true,
			icons = { "●", "○", "◆", "◇" },
		},

		-- Checkboxes: Render interactive-looking check marks and open boxes
		checkbox = {
			enabled = true,
			unchecked = { icon = "󰄱 " },
			checked = { icon = "󰱒 " },
		},

		-- Code blocks: Wrap fenced blocks in a thin border with language tag & icon
		code = {
			enabled = true,
			sign = true,
			style = "full",
			border = "thin",
			language_pad = 1,
		},

		-- Tables: Pretty-render GitHub-flavored Markdown pipe tables using box characters
		pipe_table = {
			enabled = true,
			style = "full",
			border = { "┌", "┬", "┐", "├", "┼", "┤", "└", "┴", "┘", "│", "─" },
		},

		-- Links: Prepend clean icons for hyperlinks and embedded images
		link = {
			enabled = true,
			hyperlink = "󰌹 ",
			image = "󰥶 ",
		},

		-- Window conceal options:
		-- Hides raw markup symbols (e.g. `**`, `_`, `[link](url)`) in normal mode,
		-- but reveals them automatically when cursor enters insert mode or the current line.
		win_options = {
			conceallevel = { rendered = 2, default = vim.api.nvim_get_option_value("conceallevel", {}) },
			concealcursor = { rendered = "nc", default = vim.api.nvim_get_option_value("concealcursor", {}) },
		},

		-- Buffer-type and File-type Overrides:
		-- Prevents heavy border rendering inside floating scratch buffers (like hover popups)
		-- while explicitly keeping rendering active for CodeCompanion chat buffers.
		overrides = {
			buftype = {
				nofile = {
					enabled = false,
				},
			},
			filetype = {
				codecompanion = {
					enabled = true,
				},
			},
		},
	},
}
