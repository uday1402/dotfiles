return {
	{
		"mfussenegger/nvim-dap",
		dependencies = { "mfussenegger/nvim-dap-python" },
		config = function()
			local dap = require("dap")
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

			-- Python / Debugpy
			require("dap-python").setup("/home/ud_1402/.local/share/uv/tools/debugpy/bin/python")

			table.insert(dap.configurations.python, {
				type = "python",
				request = "launch",
				name = "Launch Current File",
				program = "${file}",
				cwd = "${workspaceFolder}",
				console = "integratedTerminal",
				justMyCode = true,
			})
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
