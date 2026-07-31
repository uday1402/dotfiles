local state_file = vim.fs.joinpath(vim.fn.stdpath("state"), "last-colorscheme")

vim.opt.termguicolors = true

local function restore_last_colorscheme()
	local ok, saved = pcall(vim.fn.readfile, state_file)
	local colorscheme = ok and saved[1] or nil

	if colorscheme and colorscheme ~= "" then
		pcall(vim.cmd.colorscheme, colorscheme)
	end
end

vim.api.nvim_create_autocmd("User", {
	pattern = "LazyDone",
	once = true,
	callback = restore_last_colorscheme,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
	callback = function()
		local colorscheme = vim.g.colors_name
		if colorscheme and colorscheme ~= "" then
			pcall(function()
				vim.fn.mkdir(vim.fn.fnamemodify(state_file, ":h"), "p")
				vim.fn.writefile({ colorscheme }, state_file)
			end)
		end
	end,
})
