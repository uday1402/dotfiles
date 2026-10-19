-- ============================================================================
-- CodeCompanion.nvim Configuration & OpenRouter Free Model Setup
-- ============================================================================
--
-- ============================================================================
-- 💡 HOW TO ADD NEW MODELS DIRECTLY FROM OPENROUTER:
-- ============================================================================
-- 1. Visit: https://openrouter.ai/models?max_price=0
-- 2. Find any free model and copy its slug ID (e.g. "poolside/laguna-s-2.1:free")
-- 3. Add it to the `openrouter_models` list below!
--
--    METHOD 1: Quick Slug (Just add the string! Display name is auto-generated):
--      "cohere/north-mini-code:free",
--      "google/gemma-4-31b-it:free",
--
--    METHOD 2: Detailed Table (Custom name, description, and icon):
--      {
--        id = "poolside/laguna-s-2.1:free",
--        name = "Poolside Laguna S 2.1",
--        desc = "118B MoE coding agent (262k ctx)",
--        icon = "💻",
--      },
-- ============================================================================

local openrouter_models = {
	-- ── Free Models Router ──
	{
		id = "openrouter/free",
		name = "Free Models Router",
		desc = "Auto-routes to available free models (200k ctx)",
		icon = "🔀",
	},

	-- ── Coding Agent Models ──
	{
		id = "poolside/laguna-s-2.1:free",
		name = "Poolside Laguna S 2.1",
		desc = "118B MoE coding agent (8B active, 262k ctx)",
		icon = "💻",
	},
	{
		id = "poolside/laguna-xs-2.1:free",
		name = "Poolside Laguna XS 2.1",
		desc = "33B MoE coding agent (3B active, 262k ctx)",
		icon = "⚡",
	},
	{
		id = "cohere/north-mini-code:free",
		name = "Cohere North Mini Code",
		desc = "Cohere agentic coding MoE (256k ctx)",
		icon = "🛠️",
	},

	-- ── Google DeepMind Models ──
	{
		id = "google/gemma-4-31b-it:free",
		name = "Google Gemma 4 31B",
		desc = "DeepMind dense multimodal instruction (262k ctx)",
		icon = "🔮",
	},
	{
		id = "google/gemma-4-26b-a4b-it:free",
		name = "Google Gemma 4 26B A4B",
		desc = "DeepMind MoE instruction model (262k ctx)",
		icon = "✨",
	},

	-- ── NVIDIA Nemotron Reasoning & Orchestration ──
	{
		id = "nvidia/nemotron-3-ultra-550b-a55b:free",
		name = "NVIDIA Nemotron 3 Ultra",
		desc = "550B MoE frontier reasoning (1M ctx)",
		icon = "👑",
	},
	{
		id = "nvidia/nemotron-3-super-120b-a12b:free",
		name = "NVIDIA Nemotron 3 Super",
		desc = "120B MoE hybrid agent model (262k ctx)",
		icon = "🧠",
	},
	{
		id = "nvidia/nemotron-3.5-super-vl:free",
		name = "NVIDIA Nemotron 3.5 Super VL",
		desc = "120B MoE multimodal Vision-Language (1M ctx)",
		icon = "👁️",
	},
	{
		id = "nvidia/nemotron-3.5-lightning:free",
		name = "NVIDIA Nemotron 3.5 Lightning",
		desc = "30B MoE high-throughput agentic (1M ctx)",
		icon = "⚡",
	},
	{
		id = "nvidia/nemotron-3-nano-omni-30b-a3b-reasoning:free",
		name = "NVIDIA Nemotron 3 Nano Omni",
		desc = "30B MoE multimodal perception & reasoning (256k ctx)",
		icon = "🎯",
	},

	-- ── Thinking Machines Lab ──
	{
		id = "thinkingmachines/inkling:free",
		name = "Thinking Machines Inkling",
		desc = "975B MoE general reasoning (41B active, 1M ctx)",
		icon = "🌌",
	},
	{
		id = "thinkingmachines/inkling-small:free",
		name = "Thinking Machines Inkling Small",
		desc = "276B MoE fast multimodal reasoning (1M ctx)",
		icon = "💡",
	},

	-- ── Specialized & Long Context ──
	{
		id = "liquid/lfm-2.5-2.6b:free",
		name = "LiquidAI LFM 2.5 2.6B",
		desc = "Compact reasoning for agent workflows (65k ctx)",
		icon = "💧",
	},
	{
		id = "dots-studio/dots-3-note-preview:free",
		name = "Dots Studio Dots3-Note",
		desc = "280B MoE note & knowledge model (512k ctx)",
		icon = "📝",
	},
	{
		id = "xingchen-agi/xing4.0-29b-a4b:free",
		name = "XingChen Xing4.0 29B A4B",
		desc = "TeleAI 29B open MoE language model (262k ctx)",
		icon = "⭐",
	},
}

-- Register this model list with the AI model selector
local picker = require("config.ai_model_picker")
picker.set_models(openrouter_models)

return {
	{
		"olimorris/codecompanion.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		cmd = {
			"CodeCompanion",
			"CodeCompanionChat",
			"CodeCompanionActions",
			"CodeCompanionCmd",
		},
		keys = {
			{ "<leader>ii", "<cmd>CodeCompanion<cr>", mode = { "n", "v" }, desc = "AI: Inline Prompt (Edit/Generate)" },
			{ "<leader>ic", "<cmd>CodeCompanionChat toggle<cr>", mode = { "n", "v" }, desc = "AI: Toggle Chat" },
			{ "<leader>ia", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "AI: Actions Palette" },
			{ "<leader>if", "<cmd>CodeCompanion /fix<cr>", mode = { "v" }, desc = "AI: Fix Selected Code" },
			{ "<leader>ie", "<cmd>CodeCompanion /explain<cr>", mode = { "v" }, desc = "AI: Explain Selected Code" },
			{
				"<leader>im",
				function()
					require("config.ai_model_picker").open()
				end,
				mode = { "n" },
				desc = "AI: Switch Model (Telescope)",
			},
		},
		opts = {
			-- Target all interaction types (chat, inline, cmd) to openrouter
			interactions = {
				chat = {
					adapter = "openrouter",
				},
				inline = {
					adapter = "openrouter",
				},
				cmd = {
					adapter = "openrouter",
				},
			},
			-- Backwards compatibility with strategies
			strategies = {
				chat = {
					adapter = "openrouter",
				},
				inline = {
					adapter = "openrouter",
				},
				cmd = {
					adapter = "openrouter",
				},
			},
			-- HTTP Adapters configuration
			adapters = {
				http = {
					-- Dynamic OpenRouter adapter that always reads the currently
					-- selected model from the AI model picker!
					openrouter = function()
						local current_model = require("config.ai_model_picker").get_model()
						return require("codecompanion.adapters").extend("openrouter", {
							env = {
								api_key = "OPENROUTER_API_KEY",
							},
							schema = {
								model = {
									default = current_model,
								},
							},
						})
					end,
				},
			},
			display = {
				diff = {
					provider = "default", -- Uses Neovim's built-in diff mode
				},
			},
		},
	},
}
