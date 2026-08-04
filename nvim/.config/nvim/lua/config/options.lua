local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Tabs
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true

-- Tabline (always show; used by tabby.nvim + mouse tab clicks)
opt.showtabline = 2

-- Lualine already displays the current mode
opt.showmode = false

-- Indentations
opt.smartindent = true
vim.o.breakindent = true

vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.showbreak = "↪ "

-- show preview as you type the commands
vim.o.inccommand = "split"

-- Show which line your cursor is on
vim.o.cursorline = true

-- cursor shape
vim.o.guicursor = "n-v-c:block-blinkon0,i:block-blinkwait700-blinkon250-blinkoff400"

-- Keep the cursor constrained to actual text (disable virtual editing)
opt.virtualedit = ""

-- Enable mouse support
opt.mouse = "a"

-- Clipboard integration
vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)

-- Search behavior
opt.ignorecase = true
opt.smartcase = true

-- Better splitting
opt.splitright = true
opt.splitbelow = true

-- Keep cursor away from edges
opt.scrolloff = 6

-- Scroll six lines with <C-d> and <C-u>
opt.scroll = 6

-- Persistent undo
opt.undofile = true

-- Faster updates
opt.updatetime = 250
vim.o.timeoutlen = 300

-- Show invisible characters
opt.list = true
vim.opt.listchars = { tab = "│ ", trail = "·", nbsp = "␣" }

-- Disable swap files
opt.swapfile = false
opt.backup = false

-- signcolumn for gutter marks
vim.o.signcolumn = "yes"

vim.g.have_nerd_font = true

-- see :help confirm
vim.o.confirm = true
