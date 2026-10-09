local state_file = vim.fs.joinpath(vim.fn.stdpath("state"), "last-colorscheme")

vim.opt.termguicolors = true

local function apply_everblush_black()
	local black = "#000000"
	local dark_gray = "#161616"
	local gray = "#212121"
	local light_gray = "#565656"
	local text = "#dadada"
	local muted = "#424c50"
	local blue = "#67b0e8"
	local green = "#8ccf7e"
	local yellow = "#e5c76b"
	local red = "#e57474"
	local magenta = "#c47fd5"
	local cyan = "#6cd0ca"

	-- Replace any default #141b1e background with pure black across all highlights
	for name, _ in pairs(vim.api.nvim_get_hl(0, {})) do
		local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
		if hl.bg and string.format("#%06x", hl.bg) == "#141b1e" then
			hl.bg = black
			vim.api.nvim_set_hl(0, name, hl)
		end
	end

	-- Explicitly style core and plugin elements to black (#000000), matching Lemons
	local highlights = {
		-- Core Editor
		Normal = { fg = text, bg = black },
		NormalNC = { fg = text, bg = black },
		NormalFloat = { fg = text, bg = black },
		FloatBorder = { fg = light_gray, bg = black },
		FloatTitle = { fg = blue, bg = black, bold = true },
		SignColumn = { fg = light_gray, bg = "NONE" },
		LineNr = { fg = muted, bg = "NONE" },
		CursorLineNr = { fg = yellow, bg = "NONE", bold = true },
		CursorLine = { bg = dark_gray },
		CursorColumn = { bg = dark_gray },
		ColorColumn = { bg = dark_gray },
		EndOfBuffer = { fg = black, bg = "NONE" },
		Folded = { fg = blue, bg = dark_gray },
		FoldColumn = { fg = muted, bg = "NONE" },
		Conceal = { fg = blue, bg = "NONE" },
		NonText = { fg = light_gray, bg = "NONE" },
		MsgArea = { fg = text, bg = black },
		MsgSeparator = { fg = text, bg = black },
		WinSeparator = { fg = gray, bg = "NONE" },
		VertSplit = { fg = gray, bg = "NONE" },
		StatusLine = { fg = text, bg = gray },
		StatusLineNC = { fg = muted, bg = dark_gray },
		TabLineSel = { fg = text, bg = black, bold = true },
		TabLineFill = { bg = gray },
		TabLine = { fg = muted, bg = gray },
		Visual = { bg = gray, bold = true },
		VisualNOS = { bg = gray },

		-- Popups & Menus
		Pmenu = { fg = text, bg = dark_gray },
		PmenuSel = { fg = black, bg = yellow, bold = true },
		PmenuSbar = { bg = gray },
		PmenuThumb = { bg = light_gray },

		-- LSP & Diagnostics
		LspInlayHint = { fg = muted, bg = "NONE" },
		LspCodeLens = { fg = muted, bg = "NONE" },
		LspCodeLensSeparator = { fg = muted, bg = "NONE" },
		LspReferenceText = { bg = gray },
		LspReferenceRead = { bg = gray },
		LspReferenceWrite = { bg = gray },
		LspReferenceTarget = { bg = gray },
		LspSignatureActiveParameter = { bg = gray, bold = true },
		GitSignsCurrentLineBlame = { fg = muted, bg = "NONE" },

		-- Telescope
		TelescopeNormal = { fg = text, bg = black },
		TelescopeBorder = { fg = gray, bg = black },
		TelescopePromptNormal = { fg = text, bg = black },
		TelescopePromptBorder = { fg = gray, bg = black },
		TelescopePromptTitle = { fg = black, bg = blue, bold = true },
		TelescopePromptPrefix = { fg = red, bg = black },
		TelescopeResultsNormal = { fg = text, bg = black },
		TelescopeResultsBorder = { fg = gray, bg = black },
		TelescopeResultsTitle = { fg = black, bg = green, bold = true },
		TelescopePreviewNormal = { fg = text, bg = black },
		TelescopePreviewBorder = { fg = gray, bg = black },
		TelescopePreviewTitle = { fg = black, bg = yellow, bold = true },
		TelescopeSelection = { fg = text, bg = dark_gray, bold = true },

		-- Neo-tree
		NeoTreeNormal = { fg = text, bg = black },
		NeoTreeNormalNC = { fg = text, bg = black },
		NeoTreeEndOfBuffer = { fg = black, bg = black },
		NeoTreeWinSeparator = { fg = gray, bg = black },
		NeoTreeFloatNormal = { fg = text, bg = black },
		NeoTreeFloatBorder = { fg = light_gray, bg = black },
		NeoTreeFloatTitle = { fg = blue, bg = black, bold = true },
		NeoTreeCursorLine = { bg = dark_gray },

		-- Blink CMP
		BlinkCmpMenu = { fg = text, bg = black },
		BlinkCmpMenuBorder = { fg = light_gray, bg = black },
		BlinkCmpDoc = { fg = text, bg = black },
		BlinkCmpDocBorder = { fg = light_gray, bg = black },
		BlinkCmpSignatureHelp = { fg = text, bg = black },
		BlinkCmpSignatureHelpBorder = { fg = light_gray, bg = black },

		-- WhichKey
		WhichKeyNormal = { fg = text, bg = black },
		WhichKeyBorder = { fg = light_gray, bg = black },
		WhichKeyTitle = { fg = blue, bg = black },

		-- Trouble
		TroubleNormal = { fg = text, bg = black },
		TroubleNormalNC = { fg = text, bg = black },
		LspTroubleNormal = { fg = text, bg = black },

		-- Glance
		GlanceWinBarFilename = { fg = text, bg = black },
		GlanceWinBarFilepath = { fg = muted, bg = black },
		GlanceWinBarTitle = { fg = blue, bg = black },
		GlanceListNormal = { fg = text, bg = black },
		GlanceListBorderBottom = { fg = gray, bg = black },
		GlanceListEndOfBuffer = { fg = black, bg = black },
		GlanceListCursorLine = { bg = dark_gray },
		GlancePreviewNormal = { fg = text, bg = black },
		GlancePreviewBorderBottom = { fg = gray, bg = black },
		GlancePreviewEndOfBuffer = { fg = black, bg = black },
		GlanceBorderTop = { fg = gray, bg = black },
		GlanceIndent = { fg = muted, bg = black },
		GlanceFoldIcon = { fg = blue, bg = black },

		-- Treesitter Context
		TreesitterContext = { bg = dark_gray },
		TreesitterContextLineNumber = { fg = muted, bg = dark_gray },
		TreesitterContextBottom = { underline = true, sp = light_gray },

		-- Fzf Lua
		FzfLuaNormal = { fg = text, bg = black },
		FzfLuaBorder = { fg = light_gray, bg = black },
	}

	for group, opts in pairs(highlights) do
		vim.api.nvim_set_hl(0, group, opts)
	end

	-- Lualine integration with black background
	local lualine_theme = {
		normal = {
			a = { bg = magenta, fg = black, gui = "bold" },
			b = { bg = dark_gray, fg = cyan },
			c = { bg = black, fg = text },
		},
		insert = {
			a = { bg = green, fg = black, gui = "bold" },
			b = { bg = dark_gray, fg = green },
			c = { bg = black, fg = text },
		},
		visual = {
			a = { bg = yellow, fg = black, gui = "bold" },
			b = { bg = dark_gray, fg = yellow },
			c = { bg = black, fg = text },
		},
		replace = {
			a = { bg = red, fg = black, gui = "bold" },
			b = { bg = dark_gray, fg = red },
			c = { bg = black, fg = text },
		},
		command = {
			a = { bg = blue, fg = black, gui = "bold" },
			b = { bg = dark_gray, fg = blue },
			c = { bg = black, fg = text },
		},
		inactive = {
			a = { bg = black, fg = muted, gui = "bold" },
			b = { bg = black, fg = muted },
			c = { bg = black, fg = muted },
		},
	}

	package.loaded["lualine.themes.everblush"] = lualine_theme
	local ok, lualine = pcall(require, "lualine")
	if ok then
		pcall(lualine.setup, {
			options = {
				theme = lualine_theme,
			},
		})
	end
end

vim.api.nvim_create_autocmd("ColorScheme", {
	callback = function(args)
		if args.match == "everblush" then
			apply_everblush_black()
		else
			local ok, lualine = pcall(require, "lualine")
			if ok then
				pcall(lualine.setup, {
					options = {
						theme = "auto",
					},
				})
			end
		end
	end,
})

local function restore_last_colorscheme()
	local ok, saved = pcall(vim.fn.readfile, state_file)
	local colorscheme = ok and saved[1] or nil

	if colorscheme and colorscheme ~= "" then
		pcall(vim.cmd.colorscheme, colorscheme)
		if colorscheme == "everblush" then
			apply_everblush_black()
		end
	end
end

vim.api.nvim_create_autocmd("User", {
	pattern = "LazyDone",
	once = true,
	nested = true,
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
