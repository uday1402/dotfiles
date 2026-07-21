return {
	{
		"supermaven-inc/supermaven-nvim",

		event = "InsertEnter",

		config = function()
			require("supermaven-nvim").setup({
				keymaps = {
					accept_suggestion = "<Tab>",
					clear_suggestion = "<C-]>",
					accept_word = "<C-j>",
				},

				ignore_filetypes = {
					bigfile = true,
					oil = true,
					snacks_input = true,
				},

				color = {
					suggestion_color = "#5f8787",
					cterm = 244,
				},

				log_level = "off",
				disable_inline_completion = false,
				disable_keymaps = false,
			})
		end,

		vim.keymap.set("n", "<leader>tm", "<cmd>SupermavenToggle<cr>", { desc = "Toggle Super[M]aven", silent = true }),
	},
}
