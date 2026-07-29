return {
	-- Colorschemes
	-- nyoom.nvim ships Oxocarbon as its colorscheme.
	{
		"nyoom-engineering/oxocarbon.nvim",
		lazy = false,
		priority = 1000,
	},

	{
		"cpplain/flexoki.nvim",
		lazy = false,
		priority = 1000,
	},

	{
		"uhs-robert/oasis.nvim",
		lazy = false,
		priority = 1000,
		opts = {},
	},

	{
		"water-sucks/darkrose.nvim",
		lazy = false,
		priority = 1000,
	},

	{
		"marekh19/meowsoot.nvim",
		lazy = false,
		priority = 1000,
		opts = {},
	},

	{
		"iagorrr/noctis-high-contrast.nvim",
		lazy = false,
		priority = 1000,
	},

	{
		"rebelot/kanagawa.nvim",
		lazy = false,
		priority = 1000,
	},

	{
		"bluz71/vim-moonfly-colors",
		lazy = false,
		priority = 1000,
	},

	{
		"vague2k/vague.nvim",
		lazy = false,
		priority = 1000,
	},

	{
		"jacoborus/tender.vim",
		lazy = false,
		priority = 1000,
	},

	{
		"zenbones-theme/zenbones.nvim",
		dependencies = "rktjmp/lush.nvim",
		lazy = false,
		priority = 1000,
	},

	{
		"thesimonho/kanagawa-paper.nvim",
		lazy = false,
		priority = 1000,
	},

	{
		"datsfilipe/vesper.nvim",
		lazy = false,
		priority = 1000,
	},

	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
	},

	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		priority = 1000,
	},

	{
		"rose-pine/neovim",
		name = "rose-pine",
		lazy = false,
		priority = 1000,
	},

	{
		"Kaikacy/Lemons.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd.colorscheme("lemons")
			vim.opt.termguicolors = true
			local black = "#000000"
			vim.api.nvim_set_hl(0, "Normal", { bg = black })
			vim.api.nvim_set_hl(0, "NormalNC", { bg = black })
			vim.api.nvim_set_hl(0, "NormalFloat", { bg = black })
			vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = black })
			vim.api.nvim_set_hl(0, "SignColumn", { bg = black })
		end,
	},

	-- Colorscheme selector
	{
		"nvim-telescope/telescope.nvim",
		keys = {
			{
				"<leader>fc",
				function()
					require("telescope.builtin").colorscheme({
						enable_preview = true,
					})
				end,
				desc = "Select colorscheme",
			},
		},
	},
}
