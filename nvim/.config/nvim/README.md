This neovim configuration has the following features:

lazy.nvim > package manager

neo-tree > file explorer

blink.cmp > autocompletion

nvim-dap > debugger

nvim-dap-ui > debugger ui

telescope > fuzzy finder

which-key > key bindings

todo-comments > todo comments

Comment.nvim > commenting

indent-blankline > indentation

tabby.nvim > tabs and tab line management

flash.nvim > flash jumps and configuration

alpha > dashboard

lualine > status line

mini.nvim > multiple packages

supermaven > inline completions

conform > code formatting

smear > cursor animations

rainbow > rainbow parentheses

treesitter > syntax highlighting

fzf-lua > diagnostics, quickfix, location lists, LSP symbols and code actions

toggleterm > terminal

mason > lsp servers and linter manager

luasnip > snippets

text-objects > text objects for better nvim motions

gitsigns > git signs in the gutter

context > context aware editing inside functions, classes etc

colorscheme > lemon.lua

# USAGE DOCUMENTATIONS
---
choose the documentation provider.
  - [K / ]K — switch between documentation sources.
  - <leader>fh — search Neovim help tags.

  Inside Glance:

  - j/k — move through results.
  - <Tab> / <S-Tab> — change location.
  - <CR> — jump to the selected result.
  - v / s / t — open in vertical split, split, or tab.
  - <C-u> / <C-d> — scroll the preview.
  - q or <Esc> — close.

  Best habit: use gd or gr first, inspect several results with <Tab>, then press <CR> only when you find the right context. Use K for quick
  symbol documentation and gK when you want to inspect another available source.s.
  - gy — preview type definitions.
  - K — show contextual documentation with Hover.
  - gK —Use this workflow:

  - gd — preview definitions with Glance.
  - gr — preview references.
  - gi — preview implementation
