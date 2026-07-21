return {
	{
		"goolord/alpha-nvim",
		event = "VimEnter",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local alpha = require("alpha")
			local dashboard = require("alpha.themes.dashboard")

			-- Header (Neovim logo)
			dashboard.section.header.val = {
				"                                                                       ",
				"                                                                     ",
				"       ████ ██████           █████      ██                     ",
				"      ███████████             █████                             ",
				"      █████████ ███████████████████ ███   ███████████   ",
				"     █████████  ███    █████████████ █████ ██████████████   ",
				"    █████████ ██████████ █████████ █████ █████ ████ █████   ",
				"  ███████████ ███    ███ █████████ █████ █████ ████ █████  ",
				" ██████  █████████████████████ ████ █████ █████ ████ ██████ ",
				"                                                                       ",
			}

			-- Buttons
			dashboard.section.buttons.val = {
				dashboard.button("f", "󰱼  Find File", ":Telescope find_files<CR>"),
				dashboard.button("e", "  New File", ":ene <BAR> startinsert<CR>"),
				dashboard.button("r", "󰄉  Recent Files", ":Telescope oldfiles<CR>"),
				dashboard.button("g", "󰱼  Find Text", ":Telescope live_grep<CR>"),
				dashboard.button("c", "  Configuration", ":e ~/.config/nvim/init.lua<CR>"),
				dashboard.button("l", "󰒲  Lazy", ":Lazy<CR>"),
				dashboard.button("m", "󱐋  Mason", ":Mason<CR>"),
				dashboard.button("q", "󰗼  Quit", ":qa<CR>"),
			}

			-- Footer (dynamic)
			dashboard.section.footer.val = function()
				local stats = require("lazy").stats()
				return "⚡ Neovim loaded "
					.. stats.loaded
					.. "/"
					.. stats.count
					.. " plugins in "
					.. stats.startuptime
					.. "ms"
			end

			-- Layout
			dashboard.config.layout = {
				{ type = "padding", val = 2 },
				dashboard.section.header,
				{ type = "padding", val = 2 },
				dashboard.section.buttons,
				{ type = "padding", val = 1 },
				dashboard.section.footer,
			}

			-- Keymap: <leader>a opens dashboard
			vim.keymap.set("n", "<leader>a", function()
				vim.cmd("Alpha")
			end, { desc = "Dashboard", silent = true })

			alpha.setup(dashboard.config)
		end,
	},
}
