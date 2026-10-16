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
	local navy_highlight = "#252a45"
	local navy_select = "#30375c"

	-- Replace any default #141b1e background with transparent across all highlights
	for name, _ in pairs(vim.api.nvim_get_hl(0, {})) do
		local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
		if hl.bg and string.format("#%06x", hl.bg) == "#141b1e" then
			hl.bg = nil
			vim.api.nvim_set_hl(0, name, hl)
		end
	end

	-- Explicitly style core and plugin elements to black (#000000), matching Lemons
	local highlights = {
		-- Core Editor
		Normal = { fg = text, bg = "NONE" },
		NormalNC = { fg = text, bg = "NONE" },
		NormalFloat = { fg = text, bg = "NONE" },
		FloatBorder = { fg = light_gray, bg = "NONE" },
		FloatTitle = { fg = blue, bg = "NONE", bold = true },
		FloatShadow = { bg = "NONE" },
		FloatShadowThrough = { bg = "NONE" },
		WinBar = { fg = text, bg = "NONE" },
		WinBarNC = { fg = muted, bg = "NONE" },
		SignColumn = { fg = light_gray, bg = "NONE" },
		LineNr = { fg = muted, bg = "NONE" },
		CursorLineNr = { fg = yellow, bg = "NONE", bold = true },
		CursorLine = { bg = navy_highlight },
		CursorColumn = { bg = navy_highlight },
		ColorColumn = { bg = dark_gray },
		EndOfBuffer = { fg = black, bg = "NONE" },
		Folded = { fg = blue, bg = dark_gray },
		FoldColumn = { fg = muted, bg = "NONE" },
		Conceal = { fg = blue, bg = "NONE" },
		NonText = { fg = light_gray, bg = "NONE" },
		MsgArea = { fg = text, bg = "NONE" },
		MsgSeparator = { fg = text, bg = "NONE" },
		WinSeparator = { fg = gray, bg = "NONE" },
		VertSplit = { fg = gray, bg = "NONE" },
		StatusLine = { fg = text, bg = "NONE" },
		StatusLineNC = { fg = muted, bg = "NONE" },
		TabLineSel = { fg = text, bg = "NONE", bold = true },
		TabLineFill = { bg = "NONE" },
		TabLine = { fg = muted, bg = "NONE" },
		Visual = { bg = navy_select, bold = true },
		VisualNOS = { bg = navy_select },

		-- Popups & Menus
		Pmenu = { fg = text, bg = "NONE" },
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
		TelescopeNormal = { fg = text, bg = "NONE" },
		TelescopeBorder = { fg = gray, bg = "NONE" },
		TelescopeTitle = { fg = blue, bg = "NONE", bold = true },
		TelescopePromptNormal = { fg = text, bg = "NONE" },
		TelescopePromptBorder = { fg = gray, bg = "NONE" },
		TelescopePromptTitle = { fg = black, bg = blue, bold = true },
		TelescopePromptPrefix = { fg = red, bg = "NONE" },
		TelescopeResultsNormal = { fg = text, bg = "NONE" },
		TelescopeResultsBorder = { fg = gray, bg = "NONE" },
		TelescopeResultsTitle = { fg = black, bg = green, bold = true },
		TelescopePreviewNormal = { fg = text, bg = "NONE" },
		TelescopePreviewBorder = { fg = gray, bg = "NONE" },
		TelescopePreviewTitle = { fg = black, bg = yellow, bold = true },
		TelescopeSelection = { fg = text, bg = navy_select, bold = true },

		-- Neo-tree
		NeoTreeNormal = { fg = text, bg = "NONE" },
		NeoTreeNormalNC = { fg = text, bg = "NONE" },
		NeoTreeEndOfBuffer = { fg = "NONE", bg = "NONE" },
		NeoTreeWinSeparator = { fg = gray, bg = "NONE" },
		NeoTreeFloatNormal = { fg = text, bg = "NONE" },
		NeoTreeFloatBorder = { fg = light_gray, bg = "NONE" },
		NeoTreeFloatTitle = { fg = blue, bg = "NONE", bold = true },
		NeoTreeCursorLine = { bg = navy_highlight },

		-- Blink CMP
		BlinkCmpMenu = { fg = text, bg = "NONE" },
		BlinkCmpMenuBorder = { fg = light_gray, bg = "NONE" },
		BlinkCmpDoc = { fg = text, bg = "NONE" },
		BlinkCmpDocBorder = { fg = light_gray, bg = "NONE" },
		BlinkCmpSignatureHelp = { fg = text, bg = "NONE" },
		BlinkCmpSignatureHelpBorder = { fg = light_gray, bg = "NONE" },

		-- WhichKey
		WhichKeyNormal = { fg = text, bg = "NONE" },
		WhichKeyBorder = { fg = light_gray, bg = "NONE" },
		WhichKeyTitle = { fg = blue, bg = "NONE" },

		-- Trouble
		TroubleNormal = { fg = text, bg = "NONE" },
		TroubleNormalNC = { fg = text, bg = "NONE" },
		LspTroubleNormal = { fg = text, bg = "NONE" },

		-- Glance
		GlanceWinBarFilename = { fg = text, bg = "NONE" },
		GlanceWinBarFilepath = { fg = muted, bg = "NONE" },
		GlanceWinBarTitle = { fg = blue, bg = "NONE" },
		GlanceListNormal = { fg = text, bg = "NONE" },
		GlanceListBorderBottom = { fg = gray, bg = "NONE" },
		GlanceListEndOfBuffer = { fg = "NONE", bg = "NONE" },
		GlanceListCursorLine = { bg = navy_highlight },
		GlancePreviewNormal = { fg = text, bg = "NONE" },
		GlancePreviewBorderBottom = { fg = gray, bg = "NONE" },
		GlancePreviewEndOfBuffer = { fg = "NONE", bg = "NONE" },
		GlanceBorderTop = { fg = gray, bg = "NONE" },
		GlanceIndent = { fg = muted, bg = "NONE" },
		GlanceFoldIcon = { fg = blue, bg = "NONE" },

		-- Treesitter Context
		TreesitterContext = { bg = "NONE" },
		TreesitterContextLineNumber = { fg = muted, bg = "NONE" },
		TreesitterContextBottom = { underline = true, sp = light_gray },

		-- Fzf Lua
		FzfLuaNormal = { fg = text, bg = "NONE" },
		FzfLuaBorder = { fg = light_gray, bg = "NONE" },
	}

	for group, opts in pairs(highlights) do
		vim.api.nvim_set_hl(0, group, opts)
	end

	-- Lualine integration with black background
	local lualine_theme = {
		normal = {
			a = { bg = magenta, fg = black, gui = "bold" },
			b = { bg = dark_gray, fg = cyan },
			c = { bg = "NONE", fg = text },
		},
		insert = {
			a = { bg = green, fg = black, gui = "bold" },
			b = { bg = dark_gray, fg = green },
			c = { bg = "NONE", fg = text },
		},
		visual = {
			a = { bg = yellow, fg = black, gui = "bold" },
			b = { bg = dark_gray, fg = yellow },
			c = { bg = "NONE", fg = text },
		},
		replace = {
			a = { bg = red, fg = black, gui = "bold" },
			b = { bg = dark_gray, fg = red },
			c = { bg = "NONE", fg = text },
		},
		command = {
			a = { bg = blue, fg = black, gui = "bold" },
			b = { bg = dark_gray, fg = blue },
			c = { bg = "NONE", fg = text },
		},
		inactive = {
			a = { bg = "NONE", fg = muted, gui = "bold" },
			b = { bg = "NONE", fg = muted },
			c = { bg = "NONE", fg = muted },
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

local function make_transparent()
	local transparent_groups = {
		"Normal", "NormalNC", "NormalFloat", "FloatBorder", "FloatTitle",
		"FloatShadow", "FloatShadowThrough", "SignColumn", "LineNr", "CursorLineNr",
		"EndOfBuffer", "MsgArea", "MsgSeparator", "WinSeparator", "VertSplit",
		"StatusLine", "StatusLineNC", "TabLine", "TabLineFill", "TabLineSel",
		"WinBar", "WinBarNC", "Pmenu",
		"TelescopeNormal", "TelescopeBorder", "TelescopeTitle",
		"TelescopePromptNormal", "TelescopePromptBorder", "TelescopePromptPrefix",
		"TelescopeResultsNormal", "TelescopeResultsBorder",
		"TelescopePreviewNormal", "TelescopePreviewBorder",
		"NeoTreeNormal", "NeoTreeNormalNC", "NeoTreeEndOfBuffer", "NeoTreeWinSeparator",
		"NeoTreeFloatNormal", "NeoTreeFloatBorder", "NeoTreeFloatTitle",
		"BlinkCmpMenu", "BlinkCmpMenuBorder", "BlinkCmpDoc", "BlinkCmpDocBorder",
		"BlinkCmpSignatureHelp", "BlinkCmpSignatureHelpBorder",
		"WhichKeyNormal", "WhichKeyBorder", "WhichKeyTitle",
		"TroubleNormal", "TroubleNormalNC", "LspTroubleNormal",
		"GlanceWinBarFilename", "GlanceWinBarFilepath", "GlanceWinBarTitle",
		"GlanceListNormal", "GlanceListBorderBottom", "GlanceListEndOfBuffer",
		"GlancePreviewNormal", "GlancePreviewBorderBottom", "GlancePreviewEndOfBuffer",
		"GlanceBorderTop", "GlanceIndent", "GlanceFoldIcon",
		"FzfLuaNormal", "FzfLuaBorder",
		"TreesitterContext", "TreesitterContextLineNumber",
	}
	for _, group in ipairs(transparent_groups) do
		local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
		hl.bg = nil
		vim.api.nvim_set_hl(0, group, hl)
	end
	vim.api.nvim_set_hl(0, "CursorLine", { bg = "#252a45" })
	vim.api.nvim_set_hl(0, "CursorColumn", { bg = "#252a45" })
end

vim.api.nvim_create_autocmd("ColorScheme", {
	callback = function(args)
		if args.match == "everblush" then
			apply_everblush_black()
		else
			make_transparent()
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
