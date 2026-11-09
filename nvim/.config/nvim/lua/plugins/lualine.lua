-- ============================================================================
-- Plugin: lualine.nvim
-- Purpose: Fast, highly customizable statusline providing real-time visual
--          feedback on editor state, Git integration, LSP diagnostics, AI
--          completion status, and context-aware terminal titles.
--
-- Layout / Sections / Components:
--   lualine_a: [mode]               - Current editor mode (NORMAL, INSERT, VISUAL, etc.)
--   lualine_b: [terminal_title]     - In terminals: Lazygit / Toggleterm title & index
--              [branch, diff, diag] - In code files: Git branch, diff (+/-/~), LSP diagnostics
--   lualine_c: [filename]           - Relative file path (path = 1, hidden in terminals)
--   lualine_x: [supermaven_status]  - Supermaven AI completion state (󰚩 ON / 󰚩 OFF)
--              [encoding]           - File encoding format (e.g., utf-8)
--              [filetype]           - Filetype name and devicon
--   lualine_y: [progress]           - Cursor position percentage in buffer (e.g., 42%, Top, Bot)
--   lualine_z: [location]           - Precise cursor position coordinates (line:column)
--
-- Panel Extensions:
--   neo-tree, trouble, lazy (toggleterm omitted to retain mode indicator)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Custom Helper Functions & Status Components
-- ----------------------------------------------------------------------------

-- Supermaven Status Indicator:
-- Uses `package.loaded` check to avoid costly `require()` overhead on every
-- statusline redraw tick. Returns "󰚩 ON" when the AI engine is actively running,
-- or "󰚩 OFF" if stopped, uninitialized, or unloaded.
local function supermaven_status()
	local api = package.loaded["supermaven-nvim.api"]
	if not api then
		return "󰚩 OFF"
	end
	return api.is_running() and "󰚩 ON" or "󰚩 OFF"
end

-- Terminal buffer detection:
-- Identifies if the active buffer is a toggleterm instance or native terminal.
-- Used as a conditional toggle (`cond`) across sections B and C.
local function is_terminal()
	return vim.bo.filetype == "toggleterm" or vim.bo.buftype == "terminal"
end

-- Clean display title for terminal buffers next to the mode indicator:
-- Differentiates between lazygit sessions, numbered toggleterm instances,
-- and standard generic terminals to provide immediate spatial awareness.
local function terminal_title()
	if is_terminal() then
		local name = vim.api.nvim_buf_get_name(0)
		if name:find("lazygit") then
			return "󰊢 Lazygit"
		end
		local id = vim.b.toggle_number
		if id then
			return " Terminal #" .. id
		end
		return " Terminal"
	end
	return ""
end

-- ----------------------------------------------------------------------------
-- Plugin Specification & Configuration
-- ----------------------------------------------------------------------------

return {
	{
		"nvim-lualine/lualine.nvim",

		-- Deferred loading until UI is ready, ensuring ultra-fast Neovim startup
		event = "VeryLazy",

		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},

		opts = {
			options = {
				-- Dynamically synchronizes colors with the active theme
				theme = "auto",
				-- Single persistent statusline spanning all splits across the bottom
				globalstatus = true,
				-- Flat modern aesthetic without bulky powerline arrow glyphs
				section_separators = "",
				-- Slim vertical dividing pipes between components
				component_separators = "│",
			},

			sections = {
				-- Section A: Primary editor mode indicator (NORMAL, INSERT, VISUAL, etc.)
				lualine_a = { "mode" },

				-- Section B: Context-aware workspace information
				lualine_b = {
					-- Display friendly terminal identity when inside an active terminal
					{
						terminal_title,
						cond = is_terminal,
					},
					-- Display Git branch when editing regular code files
					{
						"branch",
						cond = function()
							return not is_terminal()
						end,
					},
					-- Display Git diff statistics (+ added, ~ modified, - removed)
					{
						"diff",
						cond = function()
							return not is_terminal()
						end,
					},
					-- Display workspace LSP diagnostic counts (errors, warnings, hints)
					{
						"diagnostics",
						cond = function()
							return not is_terminal()
						end,
					},
				},

				-- Section C: File identification
				lualine_c = {
					-- Relative file path (path = 1 gives parent/current_file.ext);
					-- hidden in terminal buffers to avoid showing raw terminal PTY paths
					{
						"filename",
						path = 1,
						cond = function()
							return not is_terminal()
						end,
					},
				},

				-- Section X: AI status and file metadata
				lualine_x = {
					-- Real-time Supermaven AI status indicator
					supermaven_status,
					-- Buffer character encoding (e.g. utf-8)
					"encoding",
					-- Filetype name accompanied by its devicon
					"filetype",
				},

				-- Section Y: Scroll progression
				lualine_y = { "progress" },

				-- Section Z: Cursor coordinates (row:col)
				lualine_z = { "location" },
			},

			-- Dedicated statusline styling for sidebars and tools.
			-- Note: toggleterm is deliberately omitted here so that lualine_a
			-- keeps displaying the active mode (e.g., TERMINAL) rather than
			-- being overwritten with a static extension label.
			extensions = {
				"neo-tree",
				"trouble",
				"lazy",
			},
		},
	},
}
