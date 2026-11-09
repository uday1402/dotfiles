-- ============================================================================
-- Plugin: Colorschemes & Theme Management
-- Purpose: Curated suite of high-contrast and aesthetically tuned Neovim
--          themes with instant startup optimization, persistent theme loading,
--          and an interactive Telescope theme picker with live preview.
--
-- Theme Persistence & Fast Startup Architecture:
--   1. Read State: Reads the last applied colorscheme from Neovim's state
--      directory (`stdpath("state")/last-colorscheme`).
--   2. Eager Load Active Theme: Only the currently saved theme plugin is loaded
--      at startup with `lazy = false` and `priority = 1000`, preventing any
--      visual flicker (FOUC) while keeping Neovim boot time minimal (<15ms).
--   3. Lazy Load Inactive Themes: All other 17+ installed theme plugins remain
--      lazy-loaded until explicitly requested.
--   4. On-Demand Loading: Changing themes via `:colorscheme <name>` dynamically
--      loads the target theme plugin through the `ColorSchemePre` autocmd.
--   5. Live Preview Picker: `<leader>fc` loads all themes on demand so Telescope
--      can preview every installed theme in real time.
--
-- Keymaps / Commands:
--   <leader>fc          (n) - Interactive colorscheme picker with live preview
--   :colorscheme <name> (c) - Switch to any installed theme (auto-loads on demand)
--
-- Available Themes:
--   kanagawa-paper, kanagawa, tokyonight, catppuccin, rose-pine, zenbones,
--   oxocarbon, flexoki, oasis, darkrose, meowsoot, noctis-high-contrast,
--   moonfly, vague, tender, vesper, Lemons, everblush
-- ============================================================================

-- ----------------------------------------------------------------------------
-- State File & Persistence Initialization
-- ----------------------------------------------------------------------------

-- Location of the persistent state file storing the user's active theme
local state_file = vim.fs.joinpath(vim.fn.stdpath("state"), "last-colorscheme")

-- Read the persisted theme name; fallback to "kanagawa-paper-ink" on fresh install
local ok, saved = pcall(vim.fn.readfile, state_file)
local saved_scheme = (ok and saved[1] and saved[1] ~= "") and saved[1] or "kanagawa-paper-ink"

-- ----------------------------------------------------------------------------
-- Colorscheme to Lazy.nvim Plugin Resolver
-- ----------------------------------------------------------------------------

-- Maps a colorscheme string (or variant name like 'kanagawa-wave', 'catppuccin-macchiato',
-- or 'rose-pine-moon') to its owning Lazy.nvim plugin repository key.
local function find_plugin_for_scheme(scheme)
	if not scheme or scheme == "" then
		return "kanagawa-paper.nvim"
	end
	scheme = scheme:lower()
	if scheme:find("^kanagawa%-paper") then
		return "kanagawa-paper.nvim"
	end
	if scheme:find("^kanagawa") then
		return "kanagawa.nvim"
	end
	if scheme:find("^tokyonight") then
		return "tokyonight.nvim"
	end
	if scheme:find("^catppuccin") then
		return "catppuccin"
	end
	if scheme:find("^rose%-pine") then
		return "rose-pine"
	end
	if scheme:find("^zen") or scheme:find("bones$") then
		return "zenbones.nvim"
	end
	if scheme:find("^oxocarbon") then
		return "oxocarbon.nvim"
	end
	if scheme:find("^flexoki") then
		return "flexoki.nvim"
	end
	if scheme:find("^oasis") then
		return "oasis.nvim"
	end
	if scheme:find("^darkrose") then
		return "darkrose.nvim"
	end
	if scheme:find("^meowsoot") then
		return "meowsoot.nvim"
	end
	if scheme:find("^noctis") then
		return "noctis-high-contrast.nvim"
	end
	if scheme:find("^moonfly") then
		return "vim-moonfly-colors"
	end
	if scheme:find("^vague") then
		return "vague.nvim"
	end
	if scheme:find("^tender") then
		return "tender.vim"
	end
	if scheme:find("^vesper") then
		return "vesper.nvim"
	end
	if scheme:find("^lemon") then
		return "Lemons.nvim"
	end
	if scheme:find("^everblush") then
		return "everblush.vim"
	end
	return nil
end

-- Determine which plugin owns the saved theme so only that one is eagerly loaded
local active_plugin = find_plugin_for_scheme(saved_scheme) or "kanagawa-paper.nvim"

-- Helper to check if a given plugin is currently active and should boot immediately
local function is_active(name)
	return name == active_plugin
end

-- ----------------------------------------------------------------------------
-- Lazy Loading & On-Demand Theme Activation
-- ----------------------------------------------------------------------------

-- Complete catalog of all theme plugins configured in this repository
local all_colorschemes = {
	"oxocarbon.nvim",
	"flexoki.nvim",
	"oasis.nvim",
	"darkrose.nvim",
	"meowsoot.nvim",
	"noctis-high-contrast.nvim",
	"kanagawa.nvim",
	"vim-moonfly-colors",
	"vague.nvim",
	"tender.vim",
	"zenbones.nvim",
	"kanagawa-paper.nvim",
	"vesper.nvim",
	"tokyonight.nvim",
	"catppuccin",
	"rose-pine",
	"Lemons.nvim",
	"everblush.vim",
}

-- Eagerly loads all theme plugins into Neovim's runtime.
-- Called before launching Telescope's picker so that all installed themes
-- appear in the selection menu and can be previewed live.
local function load_all_colorschemes()
	local to_load = {}
	local lazy_config = require("lazy.core.config")
	for _, name in ipairs(all_colorschemes) do
		local plugin = lazy_config.plugins[name]
		if plugin and not plugin._.loaded then
			table.insert(to_load, name)
		end
	end
	if #to_load > 0 then
		require("lazy").load({ plugins = to_load })
	end
end

-- Automatically load colorscheme plugin on demand if switched via `:colorscheme <name>`:
-- Intercepts the theme switch before it executes, ensuring Lazy loads the
-- plugin files first so Vim does not throw an 'E185: Cannot find color scheme' error.
vim.api.nvim_create_autocmd("ColorSchemePre", {
	callback = function(ev)
		local name = ev.match
		local plugin_name = find_plugin_for_scheme(name)
		if plugin_name then
			local plugin = require("lazy.core.config").plugins[plugin_name]
			if plugin and not plugin._.loaded then
				require("lazy").load({ plugins = { plugin_name } })
			end
		end
	end,
})

-- ----------------------------------------------------------------------------
-- Plugin Specifications
-- ----------------------------------------------------------------------------

return {
	-- Oxocarbon: Minimal IBM-inspired dark contrast palette
	{
		"nyoom-engineering/oxocarbon.nvim",
		lazy = not is_active("oxocarbon.nvim"),
		priority = is_active("oxocarbon.nvim") and 1000 or nil,
	},

	-- Flexoki: Inky, warm, paper-inspired reading colors
	{
		"cpplain/flexoki.nvim",
		lazy = not is_active("flexoki.nvim"),
		priority = is_active("flexoki.nvim") and 1000 or nil,
	},

	-- Oasis: Lush desert oasis hues with soft gradients
	{
		"uhs-robert/oasis.nvim",
		lazy = not is_active("oasis.nvim"),
		priority = is_active("oasis.nvim") and 1000 or nil,
		opts = {},
	},

	-- Darkrose: Deep moody rose palette
	{
		"water-sucks/darkrose.nvim",
		lazy = not is_active("darkrose.nvim"),
		priority = is_active("darkrose.nvim") and 1000 or nil,
	},

	-- Meowsoot: Soot-black background with pastel accents
	{
		"marekh19/meowsoot.nvim",
		lazy = not is_active("meowsoot.nvim"),
		priority = is_active("meowsoot.nvim") and 1000 or nil,
		opts = {},
	},

	-- Noctis High Contrast: Deep dark theme with vivid syntax highlights
	{
		"iagorrr/noctis-high-contrast.nvim",
		lazy = not is_active("noctis-high-contrast.nvim"),
		priority = is_active("noctis-high-contrast.nvim") and 1000 or nil,
	},

	-- Kanagawa: Japanese woodblock print aesthetic (Wave, Dragon, Lotus)
	{
		"rebelot/kanagawa.nvim",
		lazy = not is_active("kanagawa.nvim"),
		priority = is_active("kanagawa.nvim") and 1000 or nil,
	},

	-- Moonfly: Classic dark charcoal with vibrant syntax highlights
	{
		"bluz71/vim-moonfly-colors",
		lazy = not is_active("vim-moonfly-colors"),
		priority = is_active("vim-moonfly-colors") and 1000 or nil,
	},

	-- Vague: Subdued, low-contrast grayscale aesthetic
	{
		"vague2k/vague.nvim",
		lazy = not is_active("vague.nvim"),
		priority = is_active("vague.nvim") and 1000 or nil,
	},

	-- Tender: Clean 24-bit colorscheme with smooth greens and yellows
	{
		"jacoborus/tender.vim",
		lazy = not is_active("tender.vim"),
		priority = is_active("tender.vim") and 1000 or nil,
	},

	-- Zenbones: High-contrast monochrome theme family powered by Lush
	{
		"zenbones-theme/zenbones.nvim",
		dependencies = "rktjmp/lush.nvim",
		lazy = not is_active("zenbones.nvim"),
		priority = is_active("zenbones.nvim") and 1000 or nil,
	},

	-- Kanagawa Paper: Enhanced warm paper variants of Kanagawa (Ink, Paper)
	{
		"thesimonho/kanagawa-paper.nvim",
		lazy = not is_active("kanagawa-paper.nvim"),
		priority = is_active("kanagawa-paper.nvim") and 1000 or nil,
	},

	-- Vesper: Clean, high-contrast dark theme with golden accents
	{
		"datsfilipe/vesper.nvim",
		lazy = not is_active("vesper.nvim"),
		priority = is_active("vesper.nvim") and 1000 or nil,
	},

	-- Tokyo Night: Clean dark theme inspired by the lights of Tokyo
	{
		"folke/tokyonight.nvim",
		lazy = not is_active("tokyonight.nvim"),
		priority = is_active("tokyonight.nvim") and 1000 or nil,
	},

	-- Catppuccin: Soothing pastel theme family (Mocha, Macchiato, Frappe, Latte)
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = not is_active("catppuccin"),
		priority = is_active("catppuccin") and 1000 or nil,
	},

	-- Rosé Pine: Soho vibes with muted pastels (Main, Moon, Dawn)
	{
		"rose-pine/neovim",
		name = "rose-pine",
		lazy = not is_active("rose-pine"),
		priority = is_active("rose-pine") and 1000 or nil,
	},

	-- Lemons: High-contrast pitch-black theme with neon citrus accents
	{
		"Kaikacy/Lemons.nvim",
		lazy = not is_active("Lemons.nvim"),
		priority = is_active("Lemons.nvim") and 1000 or nil,
	},

	-- Everblush: Dark blue-green atmospheric theme with black/transparent tuning
	{
		"Everblush/everblush.vim",
		lazy = not is_active("everblush.vim"),
		priority = is_active("everblush.vim") and 1000 or nil,
	},

	-- ------------------------------------------------------------------------
	-- Colorscheme Selector (Telescope Integration)
	-- ------------------------------------------------------------------------
	{
		"nvim-telescope/telescope.nvim",
		keys = {
			-- <leader>fc: Dynamically loads all themes and opens Telescope picker
			-- with live real-time preview before committing the change.
			{
				"<leader>fc",
				function()
					load_all_colorschemes()
					require("telescope.builtin").colorscheme({
						enable_preview = true,
					})
				end,
				desc = "Select colorscheme",
			},
		},
	},
}
