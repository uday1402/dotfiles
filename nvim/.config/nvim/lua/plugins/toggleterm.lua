return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = function()
			require("toggleterm").setup({
				size = 15,
				open_mapping = [[<c-\>]],
				hide_numbers = true,
				shade_filetypes = {},
				start_in_insert = true,
				insert_mappings = true,
				persist_size = true,
				persist_mode = true,
				direction = "horizontal",
				auto_scroll = true,
			})

			local Terminal = require("toggleterm.terminal").Terminal

			local lazygit = Terminal:new({
				cmd = "lazygit",
				hidden = true,
				direction = "float",
				float_opts = { border = "rounded" },
			})

			vim.keymap.set("n", "<leader>gg", function()
				lazygit:toggle()
			end, { desc = "Open Lazygit" })

			vim.keymap.set("t", "jk", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
			vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]])
			vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]])
			vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]])
			vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]])
		end,
	},
}
