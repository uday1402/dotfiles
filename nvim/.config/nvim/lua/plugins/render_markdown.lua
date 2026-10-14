-- render-markdown.nvim: render markdown files with rich formatting inside Neovim
return {
	"MeanderingProgrammer/render-markdown.nvim",

	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},

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

	opts = {
		-- Render in both the current buffer and when browsing CodeCompanion chat
		file_types = { "markdown", "codecompanion" },

		-- Render headings with icons and background highlights
		heading = {
			enabled = true,
			sign = true,
			icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
		},

		-- Render bullet points with nice icons
		bullet = {
			enabled = true,
			icons = { "●", "○", "◆", "◇" },
		},

		-- Render checkboxes with status icons
		checkbox = {
			enabled = true,
			unchecked = { icon = "󰄱 " },
			checked = { icon = "󰱒 " },
		},

		-- Render code blocks with language icon and background
		code = {
			enabled = true,
			sign = true,
			style = "full",
			border = "thin",
			language_pad = 1,
		},

		-- Pretty-render pipe tables
		pipe_table = {
			enabled = true,
			style = "full",
			border = { "┌", "┬", "┐", "├", "┼", "┤", "└", "┴", "┘", "│", "─" },
		},

		-- Render links with icons
		link = {
			enabled = true,
			hyperlink = "󰌹 ",
			image = "󰥶 ",
		},

		-- Conceal raw markup for a cleaner reading experience
		win_options = {
			conceallevel = { rendered = 2, default = vim.api.nvim_get_option_value("conceallevel", {}) },
			concealcursor = { rendered = "nc", default = vim.api.nvim_get_option_value("concealcursor", {}) },
		},
	},
}
