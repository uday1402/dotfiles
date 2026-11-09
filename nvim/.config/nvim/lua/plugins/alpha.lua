-- ============================================================================
-- Plugin: alpha-nvim
-- Purpose: Fast, lightweight, and fully customizable dashboard / start screen
--          displayed when opening Neovim with no arguments.
--
-- Keymaps & Controls:
--   <leader>a       - Open / return to dashboard from any buffer
--
-- Dashboard Shortcuts (active when cursor is on the dashboard):
--   f               - Find files (Telescope find_files)
--   e               - Create new empty file and start insert mode
--   r               - Open recent files (Telescope oldfiles)
--   g               - Live text search across project (Telescope live_grep)
--   c               - Open Neovim configuration (init.lua)
--   l               - Open Lazy plugin manager UI
--   m               - Open Mason package manager UI
--   q               - Quit Neovim
--
-- Commands:
--   :Alpha          - Open the Alpha dashboard
--   :AlphaRedraw    - Redraw the dashboard
-- ============================================================================

return {
	{
		"goolord/alpha-nvim",
		-- Only load on startup if Neovim was launched without file arguments
		event = (vim.fn.argc() == 0 and "VimEnter" or nil),
		cmd = "Alpha",
		keys = {
			{ "<leader>a", "<cmd>Alpha<cr>", desc = "Dashboard" },
		},
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local alpha = require("alpha")
			local dashboard = require("alpha.themes.dashboard")

			-- Header banner: Custom Neovim logo
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

			-- Quick action buttons: Single-key shortcuts to common actions
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

			-- Dynamic footer: Displays loaded plugin count and startup time
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

			-- Layout: Spacing and ordering of dashboard sections
			dashboard.config.layout = {
				{ type = "padding", val = 2 },
				dashboard.section.header,
				{ type = "padding", val = 2 },
				dashboard.section.buttons,
				{ type = "padding", val = 1 },
				dashboard.section.footer,
			}

			-- Keymap: Open dashboard at any time
			vim.keymap.set("n", "<leader>a", function()
				vim.cmd("Alpha")
			end, { desc = "Dashboard", silent = true })

			alpha.setup(dashboard.config)
		end,
	},
}
