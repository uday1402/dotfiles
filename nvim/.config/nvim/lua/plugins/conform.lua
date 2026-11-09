-- ============================================================================
-- Plugin: conform.nvim
-- Purpose: Fast, lightweight code formatter with support for external formatters
--          and LSP formatting fallbacks.
--
-- Formatting Keymaps:
--   <leader>xf (n, v) - Format entire buffer (Normal) or selected lines (Visual)
--   <leader>tf        - Toggle autoformat-on-save globally (:FormatToggle)
--   <leader>tF        - Toggle autoformat-on-save for current buffer only (:FormatToggle!)
--
-- User Commands:
--   :FormatToggle     - Toggle autoformat-on-save globally (use ! for current buffer)
--   :FormatDisable    - Disable autoformat-on-save globally (use ! for current buffer)
--   :FormatEnable     - Enable autoformat-on-save globally (use ! for current buffer)
--   :ConformInfo      - View active formatters and log status
--
-- Configured Formatters:
--   • Lua: stylua
--   • Python: isort, black
--   • C / C++: clang-format (4-space indentation)
--   • Web (HTML/CSS/JS/TS/JSON/YAML/Markdown): prettierd / prettier
--   • Shell (sh/bash/zsh): shfmt
--   • SQL: sql_formatter
--   • CSV: csvfmt
--   • Fallback: Language Server Protocol (LSP)
-- ============================================================================

local prettier = { "prettierd", "prettier", stop_after_first = true }

local format_on_save_filetypes = {
	lua = true,
	python = true,
	json = true,
	jsonc = true,
	json5 = true,
	c = true,
	cpp = true,
	toml = true,
	html = true,
	css = true,
	scss = true,
	less = true,
	javascript = true,
	javascriptreact = true,
	typescript = true,
	typescriptreact = true,
	yaml = true,
	["yaml.docker-compose"] = true,
	["yaml.gitlab"] = true,
	["yaml.helm-values"] = true,
	sh = true,
	bash = true,
	zsh = true,
	sql = true,
	mysql = true,
	plsql = true,
	dockerfile = true,
	csv = true,
}

local function toggle_autoformat(bufnr)
	if bufnr then
		local current = vim.b[bufnr].disable_autoformat
		if current == nil then
			current = vim.g.disable_autoformat
		end
		vim.b[bufnr].disable_autoformat = not current
		local state = vim.b[bufnr].disable_autoformat and "disabled" or "enabled"
		vim.notify("Buffer autoformat " .. state, vim.log.levels.INFO, { title = "Formatting" })
	else
		vim.g.disable_autoformat = not vim.g.disable_autoformat
		local state = vim.g.disable_autoformat and "disabled" or "enabled"
		vim.notify("Global autoformat " .. state, vim.log.levels.INFO, { title = "Formatting" })
	end
end

return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = {
		"ConformInfo",
		"FormatToggle",
		"FormatEnable",
		"FormatDisable",
	},

	keys = {
		{
			"<leader>xf",
			function()
				require("conform").format({ async = true, lsp_format = "fallback" })
			end,
			mode = { "n", "v" },
			desc = "Format buffer / selection",
		},
		{
			"<leader>tf",
			function()
				toggle_autoformat()
			end,
			desc = "Toggle autoformat-on-save (global)",
		},
		{
			"<leader>tF",
			function()
				toggle_autoformat(vim.api.nvim_get_current_buf())
			end,
			desc = "Toggle autoformat-on-save (buffer)",
		},
	},

	init = function()
		vim.api.nvim_create_user_command("FormatToggle", function(args)
			toggle_autoformat(args.bang and vim.api.nvim_get_current_buf() or nil)
		end, {
			desc = "Toggle autoformat-on-save (use ! for buffer only)",
			bang = true,
		})

		vim.api.nvim_create_user_command("FormatDisable", function(args)
			if args.bang then
				vim.b.disable_autoformat = true
			else
				vim.g.disable_autoformat = true
			end
			vim.notify("Autoformat disabled" .. (args.bang and " (buffer)" or " (global)"), vim.log.levels.WARN, { title = "Formatting" })
		end, {
			desc = "Disable autoformat-on-save",
			bang = true,
		})

		vim.api.nvim_create_user_command("FormatEnable", function(args)
			if args.bang then
				vim.b.disable_autoformat = false
			else
				vim.g.disable_autoformat = false
				vim.b.disable_autoformat = nil
			end
			vim.notify("Autoformat enabled" .. (args.bang and " (buffer)" or " (global)"), vim.log.levels.INFO, { title = "Formatting" })
		end, {
			desc = "Re-enable autoformat-on-save",
			bang = true,
		})
	end,

	opts = {
		notify_on_error = false,
		format_on_save = function(bufnr)
			local disable = vim.b[bufnr].disable_autoformat
			if disable == nil then
				disable = vim.g.disable_autoformat
			end
			if disable then
				return nil
			end

			if not format_on_save_filetypes[vim.bo[bufnr].filetype] then
				return nil
			end

			local filename = vim.api.nvim_buf_get_name(bufnr)
			if filename:find("/node_modules/", 1, true) then
				return nil
			end

			return { timeout_ms = 1500 }
		end,
		default_format_opts = {
			lsp_format = "fallback",
		},
		formatters_by_ft = {
			lua = { "stylua" },
			python = { "isort", "black" },
			c = { "clang_format" },
			cpp = { "clang_format" },
			toml = { "taplo" },

			html = prettier,
			css = prettier,
			scss = prettier,
			less = prettier,
			javascript = prettier,
			javascriptreact = prettier,
			typescript = prettier,
			typescriptreact = prettier,
			json = prettier,
			jsonc = prettier,
			json5 = prettier,
			yaml = prettier,
			["yaml.docker-compose"] = prettier,
			["yaml.gitlab"] = prettier,
			["yaml.helm-values"] = prettier,
			markdown = prettier,
			mdx = prettier,

			sh = { "shfmt" },
			bash = { "shfmt" },
			zsh = { "shfmt" },
			sql = { "sql_formatter" },
			mysql = { "sql_formatter" },
			plsql = { "sql_formatter" },
			csv = { "csvfmt" },
		},
		formatters = {
			clang_format = {
				prepend_args = { "--style={IndentWidth: 4}" },
			},
			prettier = {
				prepend_args = { "--tab-width", "4", "--config-precedence", "prefer-file" },
			},
			prettierd = {
				env = {
					PRETTIERD_DEFAULT_CONFIG = vim.fn.stdpath("config") .. "/.prettierrc.json",
				},
			},
			csvfmt = {
				command = "csvfmt",
				stdin = true,
			},
		},
	},
}
