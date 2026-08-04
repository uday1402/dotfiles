local M = {}

local function js_debug_adapter_path()
	local executable = vim.fn.exepath("js-debug-adapter")
	if executable ~= "" then
		return executable
	end

	local mason_bin = vim.env.MASON
		and vim.fs.joinpath(vim.env.MASON, "bin", "js-debug-adapter")
		or vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin", "js-debug-adapter")
	return mason_bin
end

local function browser_url()
	return vim.fn.input("URL: ", "http://localhost:8080")
end

function M.setup()
	local dap = require("dap")
	local dap_utils = require("dap.utils")

	local adapter = {
		type = "server",
		host = "127.0.0.1",
		port = "${port}",
		executable = {
			command = js_debug_adapter_path(),
			args = { "${port}" },
		},
	}
	-- Each alias gets its own table: nvim-dap may augment adapter definitions.
	dap.adapters["pwa-node"] = vim.deepcopy(adapter)
	dap.adapters["pwa-chrome"] = vim.deepcopy(adapter)

	local skip_files = {
		"<node_internals>/**",
		"${workspaceFolder}/node_modules/**",
	}

	local node_launch_configuration = {
		name = "Launch Current File (Node)",
		type = "pwa-node",
		request = "launch",
		program = "${file}",
		cwd = "${workspaceFolder}",
		runtimeExecutable = "node",
		sourceMaps = true,
		skipFiles = skip_files,
	}

	local node_attach_configuration = {
		name = "Attach to Node Process",
		type = "pwa-node",
		request = "attach",
		processId = dap_utils.pick_process,
		cwd = "${workspaceFolder}",
		sourceMaps = true,
		skipFiles = skip_files,
	}

	local chrome_configuration = {
		name = "Launch Chrome (localhost:8080)",
		type = "pwa-chrome",
		request = "launch",
		url = browser_url,
		webRoot = "${workspaceFolder}",
		sourceMaps = true,
		skipFiles = skip_files,
		userDataDir = false,
	}

	-- Only plain JavaScript is directly runnable by Node without an additional
	-- transform/runtime. JSX and TypeScript buffers retain process attach and
	-- browser launch configurations for SSR/dev-server workflows.
	dap.configurations.javascript = vim.deepcopy({
		node_launch_configuration,
		node_attach_configuration,
		chrome_configuration,
	})
	for _, filetype in ipairs({ "javascriptreact", "typescript", "typescriptreact" }) do
		dap.configurations[filetype] = vim.deepcopy({
			node_attach_configuration,
			chrome_configuration,
		})
	end
	local browser_configuration = {
		chrome_configuration,
	}
	for _, filetype in ipairs({ "html", "css", "scss", "less" }) do
		dap.configurations[filetype] = vim.deepcopy(browser_configuration)
	end
end

return M
