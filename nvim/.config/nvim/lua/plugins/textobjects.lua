-- ============================================================================
-- Plugin: nvim-treesitter-textobjects
-- Purpose: Syntax-aware text objects and AST-based code motions powered by Tree-sitter.
--
-- How to Use Text Objects (in Visual 'v' or with Operators: d, c, y):
--   af / if           - Around / Inner Function
--                       • daf : Delete entire function (header + body)
--                       • cif : Clear function body and enter Insert mode
--                       • yaf : Copy (yank) entire function
--   ac / ic           - Around / Inner Class / Struct
--                       • dac : Delete class definition and contents
--                       • vic : Visually select inside of class body
--   aa / ia           - Around / Inner Argument / Parameter
--                       • daa : Delete function parameter and its surrounding comma
--                       • cia : Change argument value cleanly without touching commas
--
-- AST Navigation Motions (Normal, Visual, Operator modes):
--   ]f / [f           - Jump to Next / Previous function start
--   ]c / [c           - Jump to Next / Previous class start
--   (Jumps are recorded in Neovim's jumplist; use <C-o> to jump back, <C-i> forward)
-- ============================================================================

return {
	"nvim-treesitter/nvim-treesitter-textobjects",

	event = "BufReadPost",

	dependencies = {
		"nvim-treesitter/nvim-treesitter",
	},

	config = function()
		require("nvim-treesitter-textobjects").setup({
			select = {
				-- Automatically jump forward to the nearest text object if cursor is not directly on it
				lookahead = true,
			},
			move = {
				-- Track AST motions in Neovim's jumplist (<C-o> / <C-i>)
				set_jumps = true,
			},
		})

		local select = require("nvim-treesitter-textobjects.select")
		local move = require("nvim-treesitter-textobjects.move")

		-- ------------------------------------------------------------------------
		-- Text Object Selections (Visual 'x' & Operator-Pending 'o' modes)
		-- ------------------------------------------------------------------------

		-- Functions: 'af' includes header/closing; 'if' targets body contents
		vim.keymap.set({ "x", "o" }, "af", function()
			select.select_textobject("@function.outer", "textobjects")
		end, { desc = "Around function" })

		vim.keymap.set({ "x", "o" }, "if", function()
			select.select_textobject("@function.inner", "textobjects")
		end, { desc = "Inner function" })

		-- Classes: 'ac' includes class declaration; 'ic' targets inner definitions
		vim.keymap.set({ "x", "o" }, "ac", function()
			select.select_textobject("@class.outer", "textobjects")
		end, { desc = "Around class" })

		vim.keymap.set({ "x", "o" }, "ic", function()
			select.select_textobject("@class.inner", "textobjects")
		end, { desc = "Inner class" })

		-- Parameters: 'aa' includes delimiter/comma; 'ia' targets parameter value only
		vim.keymap.set({ "x", "o" }, "aa", function()
			select.select_textobject("@parameter.outer", "textobjects")
		end, { desc = "Around parameter" })

		vim.keymap.set({ "x", "o" }, "ia", function()
			select.select_textobject("@parameter.inner", "textobjects")
		end, { desc = "Inner parameter" })

		-- ------------------------------------------------------------------------
		-- Code Navigation Motions (Normal 'n', Visual 'x', & Operator 'o' modes)
		-- ------------------------------------------------------------------------

		-- Function jumping
		vim.keymap.set({ "n", "x", "o" }, "]f", function()
			move.goto_next_start("@function.outer", "textobjects")
		end, { desc = "Next function start" })

		vim.keymap.set({ "n", "x", "o" }, "[f", function()
			move.goto_previous_start("@function.outer", "textobjects")
		end, { desc = "Previous function start" })

		-- Class jumping
		vim.keymap.set({ "n", "x", "o" }, "]c", function()
			move.goto_next_start("@class.outer", "textobjects")
		end, { desc = "Next class start" })

		vim.keymap.set({ "n", "x", "o" }, "[c", function()
			move.goto_previous_start("@class.outer", "textobjects")
		end, { desc = "Previous class start" })
	end,
}
