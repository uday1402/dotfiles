-- Web/data LSP overrides. nvim-lspconfig supplies the commands and defaults;
-- this module only narrows ambiguous filetypes and adds project-local schemas.

local function parent_dir(bufnr)
	local filename = vim.api.nvim_buf_get_name(bufnr)
	if filename == "" then
		return vim.fn.getcwd()
	end
	return vim.fs.dirname(filename)
end

local function is_action_workflow(bufnr)
	local parent = parent_dir(bufnr)
	return parent:match("[/\\]%.github[/\\]workflows$") ~= nil
		or parent:match("[/\\]%.forgejo[/\\]workflows$") ~= nil
		or parent:match("[/\\]%.gitea[/\\]workflows$") ~= nil
end

local function upward_file(bufnr, names)
	local filename = vim.api.nvim_buf_get_name(bufnr)
	local path = filename ~= "" and filename or vim.fn.getcwd()
	local found = vim.fs.find(names, { path = path, upward = true, type = "file" })[1]
	return found and vim.fs.dirname(found) or nil
end

local function package_has_tailwind(root)
	local path = vim.fs.joinpath(root, "package.json")
	local lines = vim.fn.readfile(path)
	if #lines == 0 then
		return false
	end

	local ok, package = pcall(vim.json.decode, table.concat(lines, "\n"))
	if not ok or type(package) ~= "table" then
		return false
	end

	for _, section in ipairs({ "dependencies", "devDependencies", "peerDependencies", "optionalDependencies" }) do
		if type(package[section]) == "table" and package[section].tailwindcss ~= nil then
			return true
		end
	end
	return false
end

local function tailwind_root(bufnr, on_dir)
	local config_root = upward_file(bufnr, {
		"tailwind.config.js",
		"tailwind.config.cjs",
		"tailwind.config.mjs",
		"tailwind.config.ts",
	})
	if config_root then
		on_dir(config_root)
		return
	end

	local package_root = upward_file(bufnr, { "package.json" })
	if package_root and package_has_tailwind(package_root) then
		on_dir(package_root)
	end
end

local function schema_catalog(kind)
	local ok, schemastore = pcall(require, "schemastore")
	if not ok then
		return {}
	end
	return schemastore[kind].schemas()
end

local function sqlls_cmd(dispatchers)
	local executable = vim.fn.exepath("sql-language-server")
	if executable == "" then
		return vim.lsp.rpc.start({ "sql-language-server", "up", "--method", "stdio" }, dispatchers)
	end

	local real_executable = vim.uv.fs_realpath(executable) or executable
	local package_root = vim.fs.dirname(vim.fs.dirname(real_executable))
	local protocol_root = vim.fs.joinpath(
		package_root,
		"node_modules",
		"vscode-languageserver",
		"node_modules",
		"vscode-languageserver-protocol"
	)
	local jsonrpc_root = vim.fs.joinpath(
		package_root,
		"node_modules",
		"vscode-languageserver",
		"node_modules",
		"vscode-jsonrpc"
	)
	local protocol_entry = vim.fs.joinpath(protocol_root, "lib", "common", "protocol.js")
	local node = vim.fn.exepath("node")
	if node == "" or vim.fn.filereadable(protocol_entry) ~= 1 then
		return vim.lsp.rpc.start({ executable, "up", "--method", "stdio" }, dispatchers)
	end

	-- sql-language-server 1.7.1 imports protocol subpaths that Node 24 rejects
	-- via package `exports`. Its bundled Node 14-compatible dependencies are
	-- still present, so redirect only those imports at process startup.
	local script = table.concat({
		"const path=require('path'),M=require('module'),O=M._resolveFilename;",
		"const proto=",
		vim.json.encode(protocol_root),
		",rpc=",
		vim.json.encode(jsonrpc_root),
		";const resolve=(root,s)=>{const p=path.join(root,s);return path.extname(p)?p:p+'.js'};",
		"M._resolveFilename=function(r,p,...a){",
		"if(r==='vscode-languageserver-protocol'||r==='vscode-languageserver-protocol/'||r==='vscode-languageserver-protocol/node')return path.join(proto,'lib/node/main.js');",
		"if(r.startsWith('vscode-languageserver-protocol/'))return resolve(proto,r.slice(31));",
		"if(r==='vscode-jsonrpc'||r==='vscode-jsonrpc/'||r==='vscode-jsonrpc/node')return path.join(rpc,'lib/node/main.js');",
		"if(r.startsWith('vscode-jsonrpc/'))return resolve(rpc,r.slice(15));",
		"return O.call(this,r,p,...a)};",
		"require(",
		vim.json.encode(real_executable),
		");",
	})

	return vim.lsp.rpc.start({
		node,
		"-e",
		script,
		"sql-language-server",
		"up",
		"--method",
		"stdio",
	}, dispatchers)
end

-- Compose needs its own filetype so yamlls cannot compete with the compose LSP.
vim.filetype.add({
	pattern = {
		[".*/docker%-compose%.yaml"] = "yaml.docker-compose",
		[".*/docker%-compose%.yml"] = "yaml.docker-compose",
		[".*/compose%.yaml"] = "yaml.docker-compose",
		[".*/compose%.yml"] = "yaml.docker-compose",
	},
})

return {
	-- Keep explicit keys for all web/data servers so this table is the single
	-- place to discover their local overrides. Empty entries retain upstream
	-- nvim-lspconfig behavior.
	html = {},
	cssls = {},
	ts_ls = {},
	eslint = {},
	jsonls = {
		filetypes = { "json", "jsonc", "json5" },
		settings = {
			json = {
				schemas = schema_catalog("json"),
			},
		},
	},
	tailwindcss = {
		-- Do not attach to every git checkout: require a Tailwind config or a
		-- package.json dependency, while retaining upstream settings/filetypes.
		root_dir = tailwind_root,
	},
	emmet_language_server = {},
	sqlls = {
		-- sql-language-server is useful in ordinary git projects too.
		root_markers = { ".sqllsrc.json", ".git" },
		cmd = sqlls_cmd,
	},
	taplo = {},
	yamlls = {
		-- Compose and CI workflow buffers are owned by their dedicated servers.
		filetypes = { "yaml", "yaml.gitlab", "yaml.helm-values" },
		root_dir = function(bufnr, on_dir)
			if is_action_workflow(bufnr) then
				return
			end
			on_dir(vim.fs.root(bufnr, { ".git" }) or parent_dir(bufnr))
		end,
		settings = {
			redhat = { telemetry = { enabled = false } },
			yaml = {
				format = { enable = true },
				schemaStore = { enable = false, url = "" },
				schemas = schema_catalog("yaml"),
			},
		},
	},
	bashls = {},
	dockerls = {},
	docker_compose_language_service = {},
	-- The upstream root_dir restriction (only .github/.forgejo/.gitea
	-- workflows) is intentionally left untouched.
	gh_actions_ls = {},
}
