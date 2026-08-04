return {
	{
		"mfussenegger/nvim-dap",
		dependencies = { "mfussenegger/nvim-dap-python" },
		config = function()
			local dap = require("dap")
			local dap_python = require("dap-python")
			local dap_utils = require("dap.utils")
			local map = vim.keymap.set

			-- Keymaps
			map("n", "<leader>db", dap.toggle_breakpoint, { desc = "DAP: Toggle Breakpoint" })
			map("n", "<leader>dc", dap.continue, { desc = "DAP: Continue" })
			map("n", "<leader>dn", dap.step_over, { desc = "DAP: Step Over" })
			map("n", "<leader>di", dap.step_into, { desc = "DAP: Step Into" })
			map("n", "<leader>do", dap.step_out, { desc = "DAP: Step Out" })
			map("n", "<leader>dt", dap.terminate, { desc = "DAP: Terminate" })
			map("n", "<leader>dr", dap.repl.toggle, { desc = "DAP: REPL" })
			map("n", "<leader>du", function()
				require("dapui").toggle({})
			end, { desc = "DAP: UI" })

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

	{
		"rcarriga/nvim-dap-ui",
		dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			dapui.setup()

			-- Auto open/close DAP UI
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

	{
		"theHamsta/nvim-dap-virtual-text",
		dependencies = { "mfussenegger/nvim-dap", "nvim-treesitter/nvim-treesitter" },
		opts = {
			commented = true,
			only_first_definition = true,
			all_references = false,
			clear_on_continue = false,
			virt_text_pos = "eol",
		},
	},
}
