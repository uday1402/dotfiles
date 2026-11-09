-- ============================================================================
-- Plugin: supermaven-nvim
-- Purpose: Fast, low-latency AI inline completion and code suggestions.
--
-- Suggestions State:
--   Disabled (OFF) by default upon editor startup.
--   Toggle on/off anytime using <leader>tm or :SupermavenToggle.
--   Status is displayed in the statusline (Lualine: 󰚩 SM ON / 󰚩 SM OFF).
--
-- Keymaps (when an inline ghost-text suggestion appears in Insert mode):
--   <Tab>             - Accept full completion suggestion
--   <C-j>             - Accept only the next word of the suggestion
--   <C-e>             - Clear / dismiss current suggestion
--
-- Toggle Keymap & Commands:
--   <leader>tm        - Toggle Supermaven ON / OFF
--   :SupermavenToggle - Toggle suggestions
--   :SupermavenStart  - Turn suggestions ON
--   :SupermavenStop   - Turn suggestions OFF
--   :SupermavenStatus - Check current running state
-- ============================================================================

return {
	{
		"supermaven-inc/supermaven-nvim",

		event = "InsertEnter",
		cmd = {
			"SupermavenToggle",
			"SupermavenStart",
			"SupermavenStop",
			"SupermavenRestart",
			"SupermavenStatus",
		},

		keys = {
			{
				"<leader>tm",
				"<cmd>SupermavenToggle<cr>",
				desc = "Toggle Super[M]aven",
				silent = true,
			},
		},

		config = function()
			require("supermaven-nvim").setup({
				-- Keymaps active during insert mode completion preview
				keymaps = {
					accept_suggestion = "<Tab>", -- Accept entire ghost-text suggestion
					clear_suggestion = "<C-e>", -- Dismiss suggestion without accepting
					accept_word = "<C-j>", -- Accept only the next word
				},

				-- Buffers/filetypes where inline suggestions are always suppressed
				ignore_filetypes = {
					bigfile = true,
					oil = true,
					snacks_input = true,
				},

				-- Visual appearance of the ghost-text preview
				color = {
					suggestion_color = "#5f8787",
					cterm = 244,
				},

				log_level = "off",
				disable_inline_completion = false,
				disable_keymaps = false,
			})

			-- Disable suggestions by default on startup
			require("supermaven-nvim.api").stop()
		end,
	},
}
