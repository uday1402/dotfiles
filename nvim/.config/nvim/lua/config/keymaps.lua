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

map("n", "<C-k>", vim.lsp.buf.signature_help, { desc = "Signature help" })

map("n", "<leader>xrn", vim.lsp.buf.rename, { desc = "Rename symbol" })

map("n", "<leader>dd", vim.diagnostic.open_float, { desc = "Show diagnostic" })

local function jump_diagnostic(count)
	return function()
		local diagnostic = vim.diagnostic.jump({ count = count })
		if diagnostic then
			vim.schedule(function()
				vim.diagnostic.open_float({ scope = "cursor", focus = false })
			end)
		end
	end
end

map("n", "]d", jump_diagnostic(1), { desc = "Next diagnostic" })
map("n", "[d", jump_diagnostic(-1), { desc = "Previous diagnostic" })

-- Center screen after LSP jumps
map("n", "gd", function()
	vim.lsp.buf.definition()
	vim.cmd("normal! zz")
end, { desc = "Go to definition (centered)" })
map("n", "gr", function()
	vim.lsp.buf.references()
	vim.cmd("normal! zz")
end, { desc = "Find references (centered)" })
