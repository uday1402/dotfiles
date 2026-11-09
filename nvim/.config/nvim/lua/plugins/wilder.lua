-- ============================================================================
-- Plugin: wilder.nvim
-- Purpose: Visual floating popup replacement for the command-line completion menu.
--
-- How to Use:
--   - Modes: Automatically activates when typing in command mode (:) or search (/, ?).
--   - Trigger: Press <Tab> while typing a command, file path, or search query.
--
-- Default Controls (inside completion menu):
--   <Tab> / <Down>    - Next suggestion
--   <S-Tab> / <Up>    - Previous suggestion
--   <CR>              - Accept selected suggestion and execute
--   <Right>           - Expand / accept sub-command or directory path
--   <C-e>             - Cancel completion and revert input
-- ============================================================================

return {
	"gelguy/wilder.nvim",
	event = "CmdlineEnter",
	dependencies = {
		"romgrk/fzy-lua-native", -- provides fuzzy sorting/matching
	},
	build = ":UpdateRemotePlugins",

	config = function()
		local wilder = require("wilder")

		-- Enable completions for commands (:) and forward/backward search (/, ?)
		wilder.setup({
			modes = { ":", "/", "?" },
		})

		-- Render suggestions as a floating dropdown with character highlighting
		wilder.set_option(
			"renderer",
			wilder.popupmenu_renderer({
				highlighter = wilder.lua_fzy_highlighter(),
			})
		)
	end,
}
