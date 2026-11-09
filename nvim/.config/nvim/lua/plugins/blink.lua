-- ============================================================================
-- Plugin: blink.cmp
-- Purpose: High-performance completion engine with Rust fuzzy-matching backend.
--
-- Completion Popup Controls (Insert Mode):
--   <C-n> / <Down>    - Select next completion item
--   <C-p> / <Up>      - Select previous completion item
--   <CR>              - Accept selected completion
--   <C-e>             - Hide / dismiss completion menu
--   <K>               - Toggle documentation window for highlighted item
--
-- Active Completion Sources:
--   • lsp             - Semantic code completions from Language Servers
--   • path            - Filesystem paths
--   • snippets        - Code snippets from friendly-snippets
--   • dadbod          - Database tables/columns (active only in SQL buffers)
--   • buffer          - Disabled (buffer words will not pollute the popup)
--
-- Features:
--   • Automatic signature help window while typing function arguments
--   • Pyright overload deduplication filter
-- ============================================================================

-- Keep only the server-selected overload in signature help. Blink otherwise
-- renders every label returned by Pyright, which can look like duplicate
-- signatures for overloaded functions.
local function use_active_signature(source, context, callback)
	return source:get_signature_help(context, function(signature_help)
		if not signature_help or #signature_help.signatures <= 1 then
			callback(signature_help)
			return
		end

		local active_index = (signature_help.activeSignature or 0) + 1
		local active_signature = signature_help.signatures[active_index] or signature_help.signatures[1]

		signature_help.signatures = { active_signature }
		signature_help.activeSignature = 0
		callback(signature_help)
	end)
end

return {
	"saghen/blink.cmp",

	version = "*",

	dependencies = {
		"rafamadriz/friendly-snippets",
	},

	opts = {
		-- --------------------------------------------------------------------
		-- In-Menu Keymaps
		-- --------------------------------------------------------------------
		keymap = {
			preset = "none",
			["<K>"] = { "show", "show_documentation", "hide_documentation" },
			["<C-e>"] = { "hide" },
			["<Up>"] = { "select_prev", "fallback" },
			["<Down>"] = { "select_next", "fallback" },
			["<C-p>"] = { "select_prev", "fallback" },
			["<C-n>"] = { "select_next", "fallback" },
			["<CR>"] = { "accept", "fallback" },
		},

		appearance = {
			nerd_font_variant = "mono",
		},

		-- Documentation popup (opened via <K>)
		completion = {
			documentation = {
				auto_show = false,
				auto_show_delay_ms = 200,
			},
		},

		-- Automatic signature help popup while typing function arguments
		signature = {
			enabled = true,
			window = {
				border = "rounded",
				-- Keep signature concise and avoid repeating documentation text
				show_documentation = false,
			},
		},

		-- --------------------------------------------------------------------
		-- Completion Providers & Fallbacks
		-- --------------------------------------------------------------------
		sources = {
			default = {
				"lsp",
				"path",
				"snippets",
			},

			-- Dadbod is an additional provider enabled specifically for SQL buffers
			per_filetype = {
				sql = { "dadbod", inherit_defaults = true },
				mysql = { "dadbod", inherit_defaults = true },
				plsql = { "dadbod", inherit_defaults = true },
			},

			providers = {
				lsp = {
					name = "LSP",
					module = "blink.cmp.sources.lsp",
					fallbacks = {}, -- Do not fall back to buffer words
					override = {
						get_signature_help = use_active_signature,
					},
				},
				path = {
					name = "Path",
					module = "blink.cmp.sources.path",
					score_offset = 3,
					fallbacks = {}, -- Do not fall back to buffer words
				},
				snippets = {
					name = "Snippets",
					module = "blink.cmp.sources.snippets",
					score_offset = -1,
				},
				buffer = {
					name = "Buffer",
					module = "blink.cmp.sources.buffer",
					enabled = false, -- Disable buffer words from appearing in completion popup
				},
				dadbod = {
					name = "Dadbod",
					module = "vim_dadbod_completion.blink",
				},
			},
		},

		fuzzy = {
			implementation = "prefer_rust_with_warning",
		},
	},
}
