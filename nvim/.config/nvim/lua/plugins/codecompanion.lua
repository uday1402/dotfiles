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
		},
		opts = {
			strategies = {
				chat = {
					adapter = "openrouter",
				},
				inline = {
					adapter = "openrouter",
				},
			},
			adapters = {
				openrouter = function()
					return require("codecompanion.adapters").extend("openrouter", {
						env = {
							api_key = "OPENROUTER_API_KEY",
						},
						schema = {
							model = {
								-- Popular Free OpenRouter Models:
								-- "meta-llama/llama-3.3-70b-instruct:free"  (Default, strong reasoning & coding)
								-- "qwen/qwen-2.5-coder-32b-instruct:free"   (Specialized for code generation)
								-- "deepseek/deepseek-r1:free"               (Deep reasoning & algorithmic problem solving)
								-- "google/gemini-2.0-flash-exp:free"        (Ultra-low latency)
								default = "meta-llama/llama-3.3-70b-instruct:free",
							},
						},
					})
				end,
				gemini = function()
					return require("codecompanion.adapters").extend("gemini", {
						schema = {
							model = {
								default = "gemini-2.0-flash",
							},
						},
					})
				end,
			},
			display = {
				diff = {
					provider = "default", -- Uses Neovim's built-in diff mode
				},
			},
		},
	},
}
