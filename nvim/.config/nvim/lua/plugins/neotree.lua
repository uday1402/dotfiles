-- neotree is a filetree sidebar(similar to VS Code), and provides git status for files also

return {
  {
    'nvim-neo-tree/neo-tree.nvim',

    branch = 'v3.x',

    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },

    lazy = false,

    config = function()
      require('neo-tree').setup {

        close_if_last_window = true,
        popup_border_style = 'rounded',

        -- git integrations
        enable_git_status = true,
        enable_diagnostics = true,

        filesystem = {
          follow_current_file = {
            enabled = true,
          },   -- automatically follows the current file
          hijack_netrw_behavior = 'open_current',  -- makes neotree default(replacing netrw)

          filtered_items = {
            visible = false,   -- filtered items invisible
            hide_dotfiles = false,
            hide_gitignored = false,
          },
        },

        -- window configurations
        window = {
          position = 'left',
          width = 32,

          mappings = {
            ['<space>'] = 'none',

            -- open file in horizontal split:
            ['s'] = 'open_split',

            -- Open file in vertical split
            ['v'] = 'open_vsplit',

            ['R'] = 'refresh',  -- Refresh Explorer
          },
        },
      }

      -- Toggle Neo-tree:
      vim.keymap.set('n', '<leader>e', ':Neotree toggle<CR>', {
        desc = 'Toggle file explorer',
        silent = true,
      })
      -- reveal current file in neotree:
      vim.keymap.set('n', '<leader>o', ':Neotree focus reveal<CR>', {
        desc = 'Reveal current file in explorer',
        silent = true,
      })

    end,
  },
}

-- Useful Workflow Notes
--
-- <leader>e
-- Toggle explorer
--
-- <leader>o
-- Focus current file in explorer
--
-- Inside Neo-tree:
--
-- Enter -> open file
-- s     -> horizontal split
-- v     -> vertical split
-- a     -> add file
-- d     -> delete
-- r     -> rename
-- y     -> copy
-- x     -> cut
-- p     -> paste
--
