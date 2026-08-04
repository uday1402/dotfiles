-- Mason installs LSP servers, formatters, and debug adapters. nvim-lspconfig
-- still owns the upstream command/root defaults for each server.
local servers = {
	"pyright",
	"clangd",
	"lua_ls",
	"html",
	"cssls",
	"ts_ls",
	"eslint",
	"jsonls",
	"tailwindcss",
	"emmet_language_server",
	"sqlls",
	"taplo",
	"yamlls",
	"bashls",
	"dockerls",
	"docker_compose_language_service",
	"gh_actions_ls",
}

local ensured_tools = {
	-- LSP servers (Mason package names)
	"lua-language-server",
	"pyright",
	"clangd",
	"html-lsp",
	"css-lsp",
	"typescript-language-server",
	"eslint-lsp",
	"json-lsp",
	"tailwindcss-language-server",
	"emmet-language-server",
	"sqlls",
	"taplo",
	"yaml-language-server",
	"bash-language-server",
	"dockerfile-language-server",
	"docker-compose-language-service",
	"gh-actions-language-server",

	-- Formatters and debug adapters
	"stylua",
	"black",
	"isort",
	"clang-format",
	"prettierd",
	"prettier",
	"shfmt",
	"sql-formatter",
	"codelldb",
	"js-debug-adapter",
}

return {
	{
		"mason-org/mason.nvim",
		opts = {},
	},
	{
		"b0o/schemastore.nvim",
		lazy = true,
	},
	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = {
			"mason-org/mason.nvim",
			"neovim/nvim-lspconfig",
			"saghen/blink.cmp",
			"b0o/schemastore.nvim",
		},
		opts = {
			-- mason-tool-installer is the single owner of package installation.
			-- Keep this empty so mason-lspconfig only enables configured servers.
			ensure_installed = {},
			-- Mason v2 enables every installed server by default. Limit activation
			-- to the servers configured below.
			automatic_enable = servers,
		},
		config = function(_, opts)
			local capabilities = require("blink.cmp").get_lsp_capabilities()
			local web_configs = require("config.lsp.web")

			for _, server in ipairs(servers) do
				local config = web_configs[server]
				if config == nil then
					config = require("config.lsp." .. server)
				else
					config = vim.deepcopy(config)
				end

				-- Keep any server-specific capability additions (for example
				-- gh_actions_ls workspace registration) while adding Blink's LSP
				-- completion capabilities to every configured server.
				config.capabilities = vim.tbl_deep_extend(
					"force",
					vim.deepcopy(capabilities),
					config.capabilities or {}
				)
				vim.lsp.config(server, config)
			end

			require("mason-lspconfig").setup(opts)

			-- Nvim 0.12 ships :lsp, so nvim-lspconfig no longer defines :LspInfo.
			-- Keep the familiar command as an alias to the built-in health check.
			if vim.fn.exists(":LspInfo") == 0 then
				vim.api.nvim_create_user_command("LspInfo", "checkhealth vim.lsp", {
					desc = "Show LSP status (alias to :checkhealth vim.lsp)",
				})
			end
		end,
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = {
			"mason-org/mason.nvim",
			"mason-org/mason-lspconfig.nvim",
			"jay-babu/mason-nvim-dap.nvim",
		},
		opts = {
			ensure_installed = ensured_tools,
			-- Install missing tools at startup, but never mutate installed versions
			-- unless an explicit MasonToolsUpdate/UpdateSync command is requested.
			auto_update = false,
			run_on_start = true,
			start_delay = 3000,
		},
		config = function(_, opts)
			require("mason-tool-installer").setup(opts)
		end,
	},
	{
		"jay-babu/mason-nvim-dap.nvim",
		dependencies = {
			"mason-org/mason.nvim",
			"mfussenegger/nvim-dap",
		},
		opts = {
			-- These are nvim-dap adapter names; mason maps `js` to the
			-- js-debug-adapter package. Installation is centralized in
			-- mason-tool-installer above.
			ensure_installed = {},
			automatic_installation = false,
		},
		config = function(_, opts)
			require("mason-nvim-dap").setup(opts)
		end,
	},
}
