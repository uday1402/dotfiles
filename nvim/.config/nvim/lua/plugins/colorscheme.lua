return {
	-- Colorschemes
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
