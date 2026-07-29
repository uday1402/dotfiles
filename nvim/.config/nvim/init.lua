-- decides what to load on bootstrap(this is the entrypoint)
-- each line inside this file is a bootstrapping command for the folders(lua treats every file as a module, and require("file_name") is similar to the import module command(py)

-- Leader key(needs to be setup before the lazy loading)
vim.g.mapleader = " "
vim.g.maplocalleader = " "


-- order of loading the modules matters!(DO NOT CHANGE)
require("config.options")
require("config.keymaps")
require("config.autocmds")

require("config.lazy")
