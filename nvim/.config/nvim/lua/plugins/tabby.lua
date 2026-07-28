return {
	{
		"nanozuki/tabby.nvim",
		event = "VeryLazy",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			-- Always show the tabline (needed so mouse can click tabs)
			vim.o.showtabline = 2

			require("tabby").setup({
				-- Built-in layout: tabs first, active tab's windows at the end
				preset = "active_wins_at_tail",
				option = {
					-- Use nerd-font icons in the tabline
					nerdfont = true,
					-- How window/buffer names are displayed (unique/relative/tail/shorten)
					buf_name = {
						mode = "unique",
					},
				},
			})

			-- Switch between tab pages
			vim.keymap.set("n", "gt", "<cmd>tabnext<cr>", { desc = "Next tab" })
			vim.keymap.set("n", "gT", "<cmd>tabprevious<cr>", { desc = "Previous tab" })

			-- Open a new tab at the end
			vim.keymap.set("n", "<leader>tn", "<cmd>$tabnew<cr>", { desc = "New tab" })
			-- Close the current tab
			vim.keymap.set("n", "<leader>tx", "<cmd>tabclose<cr>", { desc = "Close tab" })
			-- Toggle tab jump mode (press the key shown on each tab to jump)
			vim.keymap.set("n", "<leader>tj", "<cmd>Tabby jump_to_tab<cr>", { desc = "Tab jump mode" })
			-- Rename the current tab (prompts for a name)
			vim.keymap.set("n", "<leader>tr", function()
				vim.ui.input({ prompt = "Tab name: " }, function(name)
					if name and name ~= "" then
						vim.cmd("Tabby rename_tab " .. name)
					end
				end)
			end, { desc = "Rename tab" })
			-- Toggle the tabline on (always) / off (never)
			vim.keymap.set("n", "<leader>tt", function()
				vim.o.showtabline = vim.o.showtabline == 0 and 2 or 0
			end, { desc = "Toggle tabline" })
		end,
	},
}
