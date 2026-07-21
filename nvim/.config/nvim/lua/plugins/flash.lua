return {
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		opts = {
			labels = "asdfghjklqwertyuiopzxcvbnm",
			search = {
				multi_window = true,
				forward = true,
				wrap = true,
			},
			jump = {
				jumplist = true,
			},
			label = {
				rainbow = {
					enabled = false,
				},
			},
			modes = {
				char = {
					enabled = true,
					jump_labels = true,
				},
			},
		},
		config = function(_, opts)
			local flash = require("flash")
			flash.setup(opts)

			vim.keymap.set("n", "<leader>jk", function()
				flash.jump()
			end, { desc = "Flash Jump" })

			vim.keymap.set({ "n", "x", "o" }, "<leader>jt", function()
				flash.treesitter()
			end, { desc = "Flash Treesitter" })

			vim.keymap.set("o", "r", function()
				flash.remote()
			end, { desc = "Remote Flash" })

			vim.keymap.set("c", "<C-s>", function()
				flash.toggle()
			end, { desc = "Toggle Flash Search" })
		end,
	},
}
