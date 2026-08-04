-- Autoformat with project-local tools when available, falling back to Mason's
-- PATH entries. LSP formatting remains the fallback for filetypes without a
-- dedicated formatter (notably Dockerfiles).
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
	markdown = true,
	mdx = true,
	sh = true,
	bash = true,
	zsh = true,
	sql = true,
	mysql = true,
	plsql = true,
	dockerfile = true,
}

return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	opts = {
		notify_on_error = false,
		format_on_save = function(bufnr)
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
		},
		formatters = {
			-- clang-format defaults to two-space indentation. Keep four spaces for
			-- C and C++ when formatting on save (and when formatting manually).
			clang_format = {
				prepend_args = { "--style={IndentWidth: 4}" },
			},
		},
	},
}
