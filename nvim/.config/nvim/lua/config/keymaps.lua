local map = vim.keymap.set

local opts = {
	noremap = true,
	silent = true,
}

-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<cr>", opts)

-- Better window navigation
map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)

-- Move through wrapped lines normally
map("n", "j", "gj", opts)
map("n", "k", "gk", opts)

-- Exit Insert Mode using "jk"
vim.keymap.set("i", "jk", "<Esc>", { silent = true, desc = "Exit insert mode", nowait = true })

-- Exit Terminal mode with "jk"
vim.keymap.set("t", "jk", [[<C-\><C-n>]], { silent = true, desc = "Exit terminal mode" })

-- the below config allows for the use of keymaps such as dL, yL, cL etc
vim.keymap.set({ "n", "v", "o", "x" }, "L", "$")
vim.keymap.set({ "n", "v", "o", "x" }, "H", "^")
-- Use the "D" key to delete to the end of the current line

-- commands for autocentering the cursor after jumps
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

vim.keymap.set("n", "G", "Gzz")
vim.keymap.set("n", "gg", "ggzz")

-- Split horizontally and vertically using <leader> key
map("n", "<leader>sh", ":split<CR>", { desc = "Split horizontally" })
map("n", "<leader>sv", ":vsplit<CR>", { desc = "Split vertically" })
map("n", "<leader>sx", ":wq<CR>", { desc = "Close Pane" })

-- LSP Actions keymap
map("n", "gd", vim.lsp.buf.declaration, { desc = "Go to declaration" })

map("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })

map("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation" })

map("n", "<leader>xrn", vim.lsp.buf.rename, { desc = "Rename symbol" })

-- Match the diagnostics workflow from the previous Kickstart configuration:
-- keep the buffer quiet while typing, show signs and warning/error underlines,
-- and open a float automatically after using Neovim's diagnostic jumps.
vim.diagnostic.config({
	update_in_insert = false,
	severity_sort = true,
	underline = {
		severity = {
			min = vim.diagnostic.severity.WARN,
		},
	},
	virtual_text = false,
	float = {
		border = "rounded",
		source = "if_many",
		style = "minimal",
		focusable = true,
	},
	signs = true,
	virtual_lines = false,
	jump = {
		float = true,
	},
})

map("n", "<leader>dd", vim.diagnostic.open_float, { desc = "Show line diagnostics" })
map("n", "<leader>dq", vim.diagnostic.setloclist, { desc = "Open diagnostic location list" })

-- Center screen after LSP jumps
map("n", "gd", function()
	vim.lsp.buf.definition()
	vim.cmd("normal! zz")
end, { desc = "Go to definition (centered)" })
map("n", "gr", function()
	vim.lsp.buf.references()
	vim.cmd("normal! zz")
end, { desc = "Find references (centered)" })
