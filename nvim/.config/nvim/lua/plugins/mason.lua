-- ============================================================================
-- Plugin: mason.nvim (& mason-lspconfig, mason-tool-installer, mason-nvim-dap)
-- Purpose: Unified package manager to install and manage LSP servers, DAP
--          debug adapters, linters, and formatters directly inside Neovim.
--
-- Commands:
--   :Mason                - Open the Mason graphical package manager UI.
--   :MasonUpdate          - Update the Mason package registry.
--   :MasonInstall <pkg>   - Install a specific tool package.
--   :MasonUninstall <pkg> - Uninstall a tool package.
--   :MasonLog             - Open the Mason log file for troubleshooting.
--   :MasonToolsInstall    - Trigger mason-tool-installer to install missing tools.
--   :MasonToolsUpdate     - Update all ensured tools to their latest versions.
--   :MasonToolsClean      - Uninstall packages not declared in ensured_tools.
--   :LspInfo              - Check LSP client connection status (:checkhealth vim.lsp).
--
-- Mason UI Navigation (inside :Mason floating window):
--   <CR> / i   - Install or update highlighted package
--   X          - Uninstall highlighted package
--   d          - Show package details, version, and homepage
--   <C-f>      - Filter / search packages by name or keyword
--   1 - 5      - Switch filter tabs (1: All, 2: LSP, 3: DAP, 4: Linter, 5: Formatter)
--   q / <Esc>  - Close Mason window
--
-- Features:
--   • Single-source tool provisioning via mason-tool-installer.
--   • Seamless nvim-lspconfig bridging via mason-lspconfig.
--   • Automatic Blink.cmp capability injection for all active language servers.
--   • DAP debug adapter registration with mason-nvim-dap.
--   • JSON/YAML SchemaStore integration for schema validation and auto-completion.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Configured LSP Servers
-- ----------------------------------------------------------------------------
-- These match nvim-lspconfig server names. Each server here corresponds to
-- a configuration in lua/config/lsp/<name>.lua (or lua/config/lsp/web.lua).
-- nvim-lspconfig retains upstream command and root-directory resolution logic.
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

-- ----------------------------------------------------------------------------
-- Centralized Tool Manifest
-- ----------------------------------------------------------------------------
-- Canonical package names as registered in the Mason registry.
-- mason-tool-installer ensures all packages listed here are downloaded and
-- available in Neovim's standard runtime path (`stdpath("data")/mason/bin`).
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
	-- ------------------------------------------------------------------------
	-- mason.nvim: Core package manager UI & executable installer
	-- ------------------------------------------------------------------------
	{
		"mason-org/mason.nvim",
		opts = {},
	},

	-- ------------------------------------------------------------------------
	-- schemastore.nvim: JSON & YAML schemas catalogue
	-- ------------------------------------------------------------------------
	-- Loaded lazily on demand by jsonls and yamlls server configurations.
	{
		"b0o/schemastore.nvim",
		lazy = true,
	},

	-- ------------------------------------------------------------------------
	-- mason-lspconfig.nvim: Bridge between Mason and nvim-lspconfig
	-- ------------------------------------------------------------------------
	{
		"mason-org/mason-lspconfig.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"mason-org/mason.nvim",
			"neovim/nvim-lspconfig",
			"saghen/blink.cmp",
		},
		opts = {
			-- mason-tool-installer is the single owner of package installation.
			-- Keep this empty so mason-lspconfig only enables configured servers.
			ensure_installed = {},
			-- Mason v2 enables every installed server by default. Limit activation
			-- strictly to the servers explicitly configured in the `servers` table.
			automatic_enable = servers,
		},
		config = function(_, opts)
			-- Retrieve client capabilities from Blink.cmp for fast fuzzy completion
			local capabilities = require("blink.cmp").get_lsp_capabilities()
			local web_configs = require("config.lsp.web")

			-- Configure each declared language server
			for _, server in ipairs(servers) do
				local config = web_configs[server]
				if config == nil then
					local ok, custom_config = pcall(require, "config.lsp." .. server)
					config = ok and custom_config or {}
				else
					config = vim.deepcopy(config)
				end

				-- Keep any server-specific capability additions (for example
				-- gh_actions_ls workspace registration) while adding Blink's LSP
				-- completion capabilities to every configured server.
				config.capabilities =
					vim.tbl_deep_extend("force", capabilities, config.capabilities or {})
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

	-- ------------------------------------------------------------------------
	-- mason-tool-installer.nvim: Automated background tool installer
	-- ------------------------------------------------------------------------
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		event = "VeryLazy",
		dependencies = {
			"mason-org/mason.nvim",
			"mason-org/mason-lspconfig.nvim",
			"jay-babu/mason-nvim-dap.nvim",
		},
		opts = {
			ensure_installed = ensured_tools,
			-- Install missing tools at startup, but never mutate installed versions
			-- unless an explicit :MasonToolsUpdate or :MasonToolsUpdateSync is run.
			auto_update = false,
			run_on_start = true,
			start_delay = 3000, -- Delay in ms to keep initial Neovim startup instantaneous
		},
		config = function(_, opts)
			require("mason-tool-installer").setup(opts)
		end,
	},

	-- ------------------------------------------------------------------------
	-- mason-nvim-dap.nvim: Bridge between Mason and nvim-dap
	-- ------------------------------------------------------------------------
	{
		"jay-babu/mason-nvim-dap.nvim",
		lazy = true,
		dependencies = {
			"mason-org/mason.nvim",
			"mfussenegger/nvim-dap",
		},
		opts = {
			-- Adapter installation is centralized in mason-tool-installer above
			-- (e.g. codelldb, js-debug-adapter). Keep ensure_installed empty here.
			ensure_installed = {},
			automatic_installation = false,
		},
		config = function(_, opts)
			require("mason-nvim-dap").setup(opts)
		end,
	},
}
