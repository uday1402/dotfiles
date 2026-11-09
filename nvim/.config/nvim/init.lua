-- Bytecode caching for faster startup
if vim.loader then
	vim.loader.enable()
end

-- Leader key (needs to be setup before the lazy loading)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Core configurations
require("config.options")
require("config.keymaps")
require("config.autocmds")

-- Plugin manager
require("config.lazy")

-- Colorscheme setup (after lazy so themes are available)
require("config.colorscheme")

-- Non-Mason LSP servers (loaded on demand for CSV filetypes)
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "csv", "tsv", "ssv", "psv" },
	once = true,
	callback = function()
		require("config.lsp.csv")
	end,
})
