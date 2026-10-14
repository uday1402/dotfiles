# Keymaps Added in This Session

All keymaps added during the DevDocs + Telescope layout configuration session.

---

## DevDocs (`<leader>D` prefix)

Defined in [`devdocs.lua`](lua/plugins/devdocs.lua). Registered as the
**[D]evDocs** group in [`whichkey.lua`](lua/plugins/whichkey.lua).

| Key | Mode | Command | Description |
| --- | --- | --- | --- |
| `<leader>Do` | n | `:DevdocsOpenCurrent` | Open docs for the current filetype |
| `<leader>Da` | n | `:DevdocsOpen` | Open docs (pick from all installed) |
| `<leader>Df` | n | `:DevdocsOpenCurrentFloat` | Open docs in a float (current filetype) |
| `<leader>DF` | n | `:DevdocsOpenFloat` | Open docs in a float (all installed) |
| `<leader>Di` | n | `:DevdocsInstall` | Install a documentation set |
| `<leader>Du` | n | `:DevdocsUninstall` | Uninstall a documentation set |
| `<leader>Dx` | n | `:DevdocsFetch` | Fetch / update documentation metadata |
| `q` | n | `:close` | Close the documentation buffer (set in `after_open`) |

---

## Telescope Picker Controls

Defined in the `defaults.mappings` section of
[`telescope.lua`](lua/plugins/telescope.lua). These apply to **every**
Telescope picker (find files, live grep, DevDocs, diagnostics, etc.).

### Insert mode (while typing in the prompt)

| Key | Action | Description |
| --- | --- | --- |
| `<C-p>` | `toggle_preview` | Toggle the preview pane on / off (zoom into results) |
| `<C-l>` | `cycle_layout_next` | Cycle through layout presets (see below) |
| `<C-j>` | `move_selection_next` | Move selection down |
| `<C-k>` | `move_selection_previous` | Move selection up |

### Normal mode (press `<Esc>` first)

| Key | Action | Description |
| --- | --- | --- |
| `q` | `close` | Close the picker |
| `<C-p>` | `toggle_preview` | Toggle the preview pane on / off |
| `<C-l>` | `cycle_layout_next` | Cycle through layout presets |

### Layout Presets (`<C-l>` cycles through these)

| # | Strategy | Size | Preview |
| --- | --- | --- | --- |
| 1 | Horizontal | 87 × 80 % | 55 % width (compact) |
| 2 | Horizontal | 95 × 95 % | 65 % width (maximized — **default**) |
| 3 | Vertical | 80 × 90 % | 55 % height (stacked) |

---

## Markdown Renderer (`<leader>m` prefix)

Defined in [`render_markdown.lua`](lua/plugins/render_markdown.lua). Registered as the
**[M]arkdown** group in [`whichkey.lua`](lua/plugins/whichkey.lua).

| Key | Mode | Command | Description |
| --- | --- | --- | --- |
| `<leader>mr` | n | `:RenderMarkdown toggle` | Toggle markdown rendering on / off |
| `<leader>me` | n | `:RenderMarkdown expand` | Expand all collapsible sections |
| `<leader>mc` | n | `:RenderMarkdown contract` | Contract all collapsible sections |
| `<leader>ml` | n | `:RenderMarkdown log` | Open the render-markdown debug log |

