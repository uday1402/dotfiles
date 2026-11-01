-- CSV LSP configuration.
-- Install: cargo install csv-lsp
-- Provides diagnostics (missing/extra cells, unclosed quotes) and formatting
-- for csv, tsv, ssv, and psv files.

-- Register and enable csv-lsp outside Mason since it is not in the registry.
vim.lsp.config("csv_lsp", {
	cmd = { "csv-lsp" },
	filetypes = { "csv", "tsv", "ssv", "psv" },
	root_markers = { ".git" },
})

vim.lsp.enable("csv_lsp")

return {}
