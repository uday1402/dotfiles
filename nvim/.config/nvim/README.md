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

# Web development

The web stack includes Treesitter parsers for HTML, CSS/SCSS, JavaScript/TypeScript/JSX, JSON/JSON5, YAML, TOML, Markdown, SQL, Dockerfiles, and common Git/config formats. Mason and `mason-lspconfig` manage the HTML/CSS/TypeScript, ESLint, JSON, Tailwind, Emmet, YAML, TOML, shell, SQL, Docker, and GitHub Actions language servers. `conform.nvim` formats with project-local Prettier/Prettierd, Stylua, Black/isort, clang-format, Taplo, shfmt, and sql-formatter, with LSP formatting as a fallback.

Useful checks and actions:

- `:LspInfo`, `:ConformInfo`, and `:Mason` show active clients, formatter resolution, and installed tools.
- `:MasonToolsUpdate` installs missing ensured tools and updates them on demand.
- `<leader>tl` toggles the self-contained Lua live server on port 8080 (and opens the browser). Use the DAP browser configuration against the same URL for page-JavaScript debugging; CSS is styled by the page and is not an executable debug target.
- `<leader>b` is the Database group: `<leader>bu` toggles Dadbod UI, `<leader>bf` finds a database buffer, and `<leader>ba` adds a connection. Dadbod completion is available in SQL/MySQL/PLSQL buffers through Blink.
- `<leader>d` contains nvim-dap (breakpoints, continue/step, REPL, and UI) alongside the existing diagnostics mappings. Plain JavaScript has a current-file Node launch plus Node attach and Chrome launch; TypeScript and React buffers expose Node attach and Chrome launch, so launch them with the project runner or a project `.vscode/launch.json` configuration. HTML/CSS/SCSS/LESS expose Chrome browser launch only—CSS is styled by the page, not an executable debug target.

Mason manages editor binaries, but each JavaScript project should still declare its own local development dependencies and configuration (typically `typescript`, `eslint`, and `prettier`; add Tailwind only when the project uses it). The language servers prefer project-local executables/configuration when present. This dotfiles repository intentionally has no `package.json`; do not globally npm-install project packages.

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
