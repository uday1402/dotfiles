-- ============================================================================
-- Plugin: nvim-dap (with nvim-dap-ui, nvim-dap-virtual-text, nvim-dap-python)
-- Purpose: Debug Adapter Protocol (DAP) integration for Neovim. Provides full
--          IDE-grade debugging with breakpoints, stepping, variable inspection,
--          REPL, call stacks, and inline virtual text.
--
-- Supported Languages:
--   • Python: via debugpy / nvim-dap-python (uv tool or mason)
--   • C / C++: via CodeLLDB (launch binary, launch with args, attach to pid)
--   • JS / TS: via js-debug-adapter (Node launch/attach, Chrome browser debug)
--
-- Keymaps (<leader>d):
--   <leader>db - Toggle breakpoint on current line
--   <leader>dc - Continue execution / start debug session
--   <leader>dn - Step over (next line)
--   <leader>di - Step into (enter function call)
--   <leader>do - Step out (finish and leave current function)
--   <leader>dt - Terminate active debug session
--   <leader>dr - Toggle interactive DAP REPL window
--   <leader>du - Toggle DAP UI dashboard (scopes, stacks, watches, console)
-- ============================================================================

return {
	{
		"mfussenegger/nvim-dap",
		dependencies = { 
            "mfussenegger/nvim-dap-python",
            "rcarriga/nvim-dap-ui",
            "theHamsta/nvim-dap-virtual-text"
        },
		keys = {
			{ "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "DAP: Toggle Breakpoint" },
			{ "<leader>dc", function() require("dap").continue() end, desc = "DAP: Continue" },
			{ "<leader>dn", function() require("dap").step_over() end, desc = "DAP: Step Over" },
			{ "<leader>di", function() require("dap").step_into() end, desc = "DAP: Step Into" },
			{ "<leader>do", function() require("dap").step_out() end, desc = "DAP: Step Out" },
			{ "<leader>dt", function() require("dap").terminate() end, desc = "DAP: Terminate" },
			{ "<leader>dr", function() require("dap").repl.toggle() end, desc = "DAP: REPL" },
			{ "<leader>du", function() require("dapui").toggle({}) end, desc = "DAP: UI" },
		},
		config = function()
			local dap = require("dap")
			local dap_python = require("dap-python")
			local dap_utils = require("dap.utils")
			local map = vim.keymap.set

			-- Python / Debugpy. Prefer the uv tool installation without tying the
			-- configuration to a username, and retain dap-python's full config set.
			local data_home = vim.env.XDG_DATA_HOME or vim.fn.expand("~/.local/share")
			local debugpy_adapter = vim.fn.exepath("debugpy-adapter")
			local debugpy = debugpy_adapter ~= "" and debugpy_adapter or (data_home .. "/uv/tools/debugpy/bin/python")

			dap_python.setup(debugpy)
			for _, config in ipairs(dap.configurations.python) do
				if config.name == "file" then
					config.name = "Launch Current File"
					config.cwd = "${workspaceFolder}"
					config.justMyCode = true
					break
				end
			end

			-- C / C++ / CodeLLDB
			local codelldb = vim.fn.exepath("codelldb")
			if codelldb == "" then
				codelldb = vim.fn.stdpath("data") .. "/mason/bin/codelldb"
			end

			dap.adapters.codelldb = {
				type = "server",
				port = "${port}",
				executable = {
					command = codelldb,
					args = { "--port", "${port}" },
				},
			}

			local function executable_path()
				return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
			end

			local native_configurations = {
				{
					name = "Launch executable",
					type = "codelldb",
					request = "launch",
					program = executable_path,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
					console = "integratedTerminal",
				},
				{
					name = "Launch executable with arguments",
					type = "codelldb",
					request = "launch",
					program = executable_path,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
					console = "integratedTerminal",
					args = function()
						return dap_utils.splitstr(vim.fn.input("Arguments: "))
					end,
				},
				{
					name = "Attach to process",
					type = "codelldb",
					request = "attach",
					pid = dap_utils.pick_process,
					cwd = "${workspaceFolder}",
				},
			}

			dap.configurations.c = native_configurations
			dap.configurations.cpp = native_configurations

			require("config.dap.javascript").setup()
		end,
	},

	-- UI layout manager for DAP: scopes, stacks, watches, breakpoints, and console
	{
		"rcarriga/nvim-dap-ui",
		lazy = true,
		dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			dapui.setup()

			-- Automatically open UI panels when debugging starts, and close on exit/terminate
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end
		end,
	},

	-- Inline variable values displayed as end-of-line virtual text while debugging
	{
		"theHamsta/nvim-dap-virtual-text",
		lazy = true,
		dependencies = { "mfussenegger/nvim-dap", "nvim-treesitter/nvim-treesitter" },
		opts = {
			commented = true,              -- Prefix virtual text with comment syntax
			only_first_definition = true,  -- Show virtual text only for the first variable declaration
			all_references = false,        -- Avoid repeating virtual text on every reference
			clear_on_continue = false,     -- Keep virtual text visible while running until next break
			virt_text_pos = "eol",         -- Display variable values at the end of the line
		},
	},
}
