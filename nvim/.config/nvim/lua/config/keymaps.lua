local map = vim.keymap.set

local opts = {
	noremap = true,
	silent = true,
}

local function motion_and_center(keys)
	local count = vim.v.count > 0 and tostring(vim.v.count) or ""
	local winid = vim.api.nvim_get_current_win()

	vim.cmd.normal({ args = { count .. keys }, bang = true })

	local center = function()
		if vim.api.nvim_win_is_valid(winid) then
			vim.api.nvim_win_call(winid, function()
				vim.cmd.normal({ args = { "zz" }, bang = true })
			end)
		end
	end

	local animate = rawget(_G, "MiniAnimate")
	if animate then
		animate.execute_after("scroll", center)
	else
		center()
	end
end

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

-- Execute one Normal-mode command, then return to Insert mode.
vim.keymap.set("i", "<C-o>", "<C-o>", {
	noremap = true,
	silent = true,
	desc = "Execute one Normal-mode command",
})

-- Exit Terminal mode with "jk"
vim.keymap.set("t", "jk", [[<C-\><C-n>]], { silent = true, desc = "Exit terminal mode" })

-- the below config allows for the use of keymaps such as dL, yL, cL etc
vim.keymap.set({ "n", "v", "o", "x" }, "L", "$")
vim.keymap.set({ "n", "v", "o", "x" }, "H", "^")
-- Use the "D" key to delete to the end of the current line

-- commands for autocentering the cursor after jumps
map("n", "<C-d>", function()
	motion_and_center(vim.keycode("<C-d>"))
end)
map("n", "<C-u>", function()
	motion_and_center(vim.keycode("<C-u>"))
end)

map("n", "G", function()
	motion_and_center("G")
end)
map("n", "gg", function()
	motion_and_center("gg")
end)

-- Split horizontally and vertically using <leader> key
map("n", "<leader>w", vim.cmd.write, { desc = "Save file" })
map("n", "<leader>wq", vim.cmd.wq, { desc = "Save and quit" })
map("n", "<leader>q", vim.cmd.quit, { desc = "Quit" })

map("n", "<leader>sh", ":split<CR>", { desc = "Split horizontally" })
map("n", "<leader>sv", ":vsplit<CR>", { desc = "Split vertically" })
map("n", "<leader>sx", ":wq<CR>", { desc = "Close Pane" })

local zoom_restore_by_tab = {}

map("n", "<leader>sz", function()
	local tabpage = vim.api.nvim_get_current_tabpage()
	local restore = zoom_restore_by_tab[tabpage]

	if restore then
		vim.cmd(restore)
		zoom_restore_by_tab[tabpage] = nil
		return
	end

	zoom_restore_by_tab[tabpage] = vim.fn.winrestcmd()
	vim.cmd("resize")
	vim.cmd("vertical resize")
end, { desc = "Toggle split zoom" })

-- LSP Actions keymap
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
		on_jump = function(_, bufnr)
			vim.diagnostic.open_float({
				bufnr = bufnr,
				scope = "cursor",
				focus = false,
			})
		end,
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

-- ============================================================================
-- Autoformatting Toggles & Commands (Conform)
-- ============================================================================
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
		vim.b.disable_autoformat = false
		vim.g.disable_autoformat = false
	end
	vim.notify("Autoformat enabled" .. (args.bang and " (buffer)" or " (global)"), vim.log.levels.INFO, { title = "Formatting" })
end, {
	desc = "Re-enable autoformat-on-save",
	bang = true,
})

map("n", "<leader>tf", function()
	toggle_autoformat()
end, { desc = "Toggle autoformat-on-save" })

map("n", "<leader>tF", function()
	toggle_autoformat(vim.api.nvim_get_current_buf())
end, { desc = "Toggle buffer autoformat-on-save" })

-- Manual format buffer (fallback to LSP if Conform isn't loaded)
map({ "n", "v" }, "<leader>xf", function()
	local ok, conform = pcall(require, "conform")
	if ok then
		conform.format({ async = true, lsp_format = "fallback" })
	else
		vim.lsp.buf.format({ async = true })
	end
end, { desc = "Format buffer / selection" })

-- ============================================================================
-- Linters & Syntax Checkers Toggles & Commands (Diagnostics)
-- ============================================================================
local function toggle_diagnostics(bufnr)
	if bufnr then
		local enabled = vim.diagnostic.is_enabled({ bufnr = bufnr })
		vim.diagnostic.enable(not enabled, { bufnr = bufnr })
		local state = not enabled and "enabled" or "disabled"
		vim.notify("Buffer linters & diagnostics " .. state, vim.log.levels.INFO, { title = "Diagnostics" })
	else
		local enabled = vim.diagnostic.is_enabled()
		vim.diagnostic.enable(not enabled)
		local state = not enabled and "enabled" or "disabled"
		vim.notify("Global linters & diagnostics " .. state, vim.log.levels.INFO, { title = "Diagnostics" })
	end
end

vim.api.nvim_create_user_command("DiagnosticToggle", function(args)
	toggle_diagnostics(args.bang and vim.api.nvim_get_current_buf() or nil)
end, {
	desc = "Toggle linters/diagnostics (use ! for buffer only)",
	bang = true,
})

vim.api.nvim_create_user_command("DiagnosticDisable", function(args)
	if args.bang then
		vim.diagnostic.enable(false, { bufnr = 0 })
	else
		vim.diagnostic.enable(false)
	end
	vim.notify("Linters & diagnostics turned off" .. (args.bang and " (buffer)" or " (global)"), vim.log.levels.WARN, { title = "Diagnostics" })
end, {
	desc = "Turn off linters and syntax checkers",
	bang = true,
})

vim.api.nvim_create_user_command("DiagnosticEnable", function(args)
	if args.bang then
		vim.diagnostic.enable(true, { bufnr = 0 })
	else
		vim.diagnostic.enable(true)
	end
	vim.notify("Linters & diagnostics turned on" .. (args.bang and " (buffer)" or " (global)"), vim.log.levels.INFO, { title = "Diagnostics" })
end, {
	desc = "Turn on linters and syntax checkers",
	bang = true,
})

map("n", "<leader>td", function()
	toggle_diagnostics()
end, { desc = "Toggle linters & diagnostics" })

map("n", "<leader>tD", function()
	toggle_diagnostics(vim.api.nvim_get_current_buf())
end, { desc = "Toggle buffer linters & diagnostics" })

map("n", "<leader>dt", function()
	toggle_diagnostics()
end, { desc = "Toggle linters & diagnostics" })
