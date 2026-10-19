-- ╭──────────────────────────────────────────────────────────────────────────╮
-- │  AI Model Picker for CodeCompanion (Telescope Floating Window Style)     │
-- ╰──────────────────────────────────────────────────────────────────────────╯
--
-- ============================================================================
-- HOW TO ADD NEW MODELS DIRECTLY FROM OPENROUTER:
-- ============================================================================
-- 1. Visit: https://openrouter.ai/models?max_price=0
-- 2. Find any free model and copy its Model ID / Slug:
--      Examples:
--        "poolside/laguna-s-2.1:free"
--        "cohere/north-mini-code:free"
--        "google/gemma-4-31b-it:free"
--
-- 3. Add it to the list in `lua/plugins/codecompanion.lua` (or `M.default_models` below):
--
--    METHOD A — Super Simple (just the model slug as a string):
--      "cohere/north-mini-code:free",
--      (The picker will automatically format the display name and badges for you!)
--
--    METHOD B — Custom Name & Description:
--      {
--        id = "cohere/north-mini-code:free",
--        name = "Cohere North Mini Code",
--        desc = "Agentic coding model (256k ctx)",
--      },
--
-- ============================================================================
-- HOW MODEL SWITCHING WORKS ACROSS ALL FORMATS (Chat, Inline, Cmd):
-- ============================================================================
-- CodeCompanion resolves its HTTP adapters through `config.adapters.http[name]`.
-- When you pick a model here:
--   1. The model ID is saved to state and remembered across Neovim restarts.
--   2. `config.adapters.http.openrouter` is updated to return the chosen model.
--   3. All interactions (chat, inline, cmd) route to this adapter.
--   4. If you already have an active chat buffer open, its model updates instantly.
-- ============================================================================

local M = {}

local state_file = vim.fs.joinpath(vim.fn.stdpath("state"), "codecompanion-model")

---@class ModelEntry
---@field id string    OpenRouter model slug (e.g. "poolside/laguna-s-2.1:free")
---@field name string  Display name (e.g. "Poolside Laguna S 2.1")
---@field desc string  Description or provider info
---@field icon string  Nerd-font icon or badge

-- ── Current Free Models on OpenRouter ────────────────────────────────
M.default_models = {
	-- ── Free Models Router ──
	{
		id = "openrouter/free",
		name = "Free Models Router",
		desc = "Auto-routes to available free models (200k ctx)",
		icon = "🔀",
	},

	-- ── Coding Agent Models ──
	{
		id = "poolside/laguna-s-2.1:free",
		name = "Poolside Laguna S 2.1",
		desc = "118B MoE coding agent (8B active, 262k ctx)",
		icon = "💻",
	},
	{
		id = "poolside/laguna-xs-2.1:free",
		name = "Poolside Laguna XS 2.1",
		desc = "33B MoE coding agent (3B active, 262k ctx)",
		icon = "⚡",
	},
	{
		id = "cohere/north-mini-code:free",
		name = "Cohere North Mini Code",
		desc = "Cohere agentic coding MoE (256k ctx)",
		icon = "🛠️",
	},

	-- ── Google DeepMind Models ──
	{
		id = "google/gemma-4-31b-it:free",
		name = "Google Gemma 4 31B",
		desc = "DeepMind dense multimodal instruction (262k ctx)",
		icon = "🔮",
	},
	{
		id = "google/gemma-4-26b-a4b-it:free",
		name = "Google Gemma 4 26B A4B",
		desc = "DeepMind MoE instruction model (262k ctx)",
		icon = "✨",
	},

	-- ── NVIDIA Nemotron Reasoning & Orchestration ──
	{
		id = "nvidia/nemotron-3-ultra-550b-a55b:free",
		name = "NVIDIA Nemotron 3 Ultra",
		desc = "550B MoE frontier reasoning (1M ctx)",
		icon = "👑",
	},
	{
		id = "nvidia/nemotron-3-super-120b-a12b:free",
		name = "NVIDIA Nemotron 3 Super",
		desc = "120B MoE hybrid agent model (262k ctx)",
		icon = "🧠",
	},
	{
		id = "nvidia/nemotron-3.5-super-vl:free",
		name = "NVIDIA Nemotron 3.5 Super VL",
		desc = "120B MoE multimodal Vision-Language (1M ctx)",
		icon = "👁️",
	},
	{
		id = "nvidia/nemotron-3.5-lightning:free",
		name = "NVIDIA Nemotron 3.5 Lightning",
		desc = "30B MoE high-throughput agentic (1M ctx)",
		icon = "⚡",
	},
	{
		id = "nvidia/nemotron-3-nano-omni-30b-a3b-reasoning:free",
		name = "NVIDIA Nemotron 3 Nano Omni",
		desc = "30B MoE multimodal perception & reasoning (256k ctx)",
		icon = "🎯",
	},

	-- ── Thinking Machines Lab ──
	{
		id = "thinkingmachines/inkling:free",
		name = "Thinking Machines Inkling",
		desc = "975B MoE general reasoning (41B active, 1M ctx)",
		icon = "🌌",
	},
	{
		id = "thinkingmachines/inkling-small:free",
		name = "Thinking Machines Inkling Small",
		desc = "276B MoE fast multimodal reasoning (1M ctx)",
		icon = "💡",
	},

	-- ── Specialized & Long Context ──
	{
		id = "liquid/lfm-2.5-2.6b:free",
		name = "LiquidAI LFM 2.5 2.6B",
		desc = "Compact reasoning for agent workflows (65k ctx)",
		icon = "💧",
	},
	{
		id = "dots-studio/dots-3-note-preview:free",
		name = "Dots Studio Dots3-Note",
		desc = "280B MoE note & knowledge model (512k ctx)",
		icon = "📝",
	},
	{
		id = "xingchen-agi/xing4.0-29b-a4b:free",
		name = "XingChen Xing4.0 29B A4B",
		desc = "TeleAI 29B open MoE language model (262k ctx)",
		icon = "⭐",
	},
}

---Format raw item (string slug or table) into a standard ModelEntry
---@param item string|table
---@return ModelEntry
function M.normalize_model(item)
	if type(item) == "string" then
		local slug = vim.trim(item)
		local raw = slug:match("/(.*)") or slug
		raw = raw:gsub(":free", "")
		raw = raw:gsub("%-", " "):gsub("_", " ")
		local pretty = raw:gsub("(%a)([%w_']*)", function(first, rest)
			return first:upper() .. rest
		end)
		local is_free = slug:find(":free") ~= nil or slug == "openrouter/free"
		return {
			id = slug,
			name = pretty,
			desc = is_free and "OpenRouter free model" or "OpenRouter model",
			icon = is_free and "🆓" or "💎",
		}
	elseif type(item) == "table" then
		local is_free = (item.id and item.id:find(":free") ~= nil) or item.id == "openrouter/free"
		return {
			id = item.id or "unknown",
			name = item.name or item.id or "Unknown Model",
			desc = item.desc or (is_free and "OpenRouter free model" or "OpenRouter model"),
			icon = item.icon or (is_free and "🆓" or "💎"),
		}
	end
	return { id = "unknown", name = "Unknown", desc = "", icon = "🤖" }
end

-- Active models list
M.models = {}
for _, m in ipairs(M.default_models) do
	table.insert(M.models, M.normalize_model(m))
end

---Save current model id to state file
local function persist_model(model_id)
	pcall(function()
		vim.fn.mkdir(vim.fn.fnamemodify(state_file, ":h"), "p")
		vim.fn.writefile({ model_id }, state_file)
	end)
end

---Load persisted model id from state file and select it
function M.load_persisted_model()
	local ok, lines = pcall(vim.fn.readfile, state_file)
	if ok and lines and lines[1] and lines[1] ~= "" then
		local saved_id = vim.trim(lines[1])
		for i, m in ipairs(M.models) do
			if m.id == saved_id then
				M._current_idx = i
				return
			end
		end
	end
	-- Fallback to the first model in the list and persist it
	M._current_idx = 1
	if M.models[1] then
		persist_model(M.models[1].id)
	end
end

---Set or replace the models list from codecompanion.lua
---@param list table List of strings or tables
function M.set_models(list)
	if type(list) ~= "table" or #list == 0 then
		return
	end
	local new_models = {}
	for _, item in ipairs(list) do
		table.insert(new_models, M.normalize_model(item))
	end
	M.models = new_models

	-- Restore active index if saved
	M.load_persisted_model()
end

M._current_idx = 1
M.load_persisted_model()

-- ── Public API ──────────────────────────────────────────────────────

---Returns the currently active OpenRouter model slug (e.g. "poolside/laguna-s-2.1:free")
---Used by codecompanion adapter function for every chat, inline, and cmd call.
---@return string
function M.get_model()
	local entry = M.models[M._current_idx]
	if entry and entry.id then
		return entry.id
	end
	return M.models[1] and M.models[1].id or "openrouter/free"
end

---Returns the current model display name
---@return string
function M.get_name()
	local entry = M.models[M._current_idx]
	return entry and entry.name or "AI Model"
end

---Returns status string for lualine
---@return string
function M.status()
	local entry = M.models[M._current_idx]
	if entry then
		local badge = (entry.id:find(":free") or entry.id == "openrouter/free") and "🆓" or "💎"
		return string.format("%s %s", badge, entry.name)
	end
	return "🤖 Free AI"
end

-- ── Core Model Application ──────────────────────────────────────────

---Applies the selected model across ALL CodeCompanion formats:
--- - Interactions (chat, inline, cmd)
--- - Adapter definition (config.adapters.http.openrouter)
--- - Active open chat buffer (updates instantly)
--- - Saves to state file for persistence
---@param model ModelEntry
function M.apply_model(model)
	if not model or not model.id then
		return
	end

	-- 1. Persist selection
	persist_model(model.id)

	-- 2. Fallback global variable for inline interaction
	vim.g.codecompanion_adapter = "openrouter"

	-- 3. If CodeCompanion config is loaded, update all interaction strategies & adapters
	local ok_cfg, cc_cfg = pcall(require, "codecompanion.config")
	if ok_cfg and cc_cfg then
		-- Update all interaction targets to openrouter
		if cc_cfg.interactions then
			if cc_cfg.interactions.chat then
				cc_cfg.interactions.chat.adapter = "openrouter"
			end
			if cc_cfg.interactions.inline then
				cc_cfg.interactions.inline.adapter = "openrouter"
			end
			if cc_cfg.interactions.cmd then
				cc_cfg.interactions.cmd.adapter = "openrouter"
			end
		end

		-- CRITICAL: Update adapters.http.openrouter with the new model
		if cc_cfg.adapters and cc_cfg.adapters.http then
			cc_cfg.adapters.http.openrouter = function()
				return require("codecompanion.adapters").extend("openrouter", {
					env = {
						api_key = "OPENROUTER_API_KEY",
					},
					schema = {
						model = {
							default = model.id,
						},
					},
				})
			end
		end
	end

	-- 4. If an active chat buffer is open, change its model immediately!
	local ok_cc, cc = pcall(require, "codecompanion")
	if ok_cc and cc.last_chat then
		local chat = cc.last_chat()
		if chat and chat.change_model then
			pcall(chat.change_model, chat, { model = model.id })
		end
	end

	vim.notify(
		string.format("Active Free Model: %s\nSlug: %s\nApplied to: Chat, Inline, Cmd", model.name, model.id),
		vim.log.levels.INFO,
		{ title = "CodeCompanion Model Changed" }
	)
end

-- ── UI State & Windows ──────────────────────────────────────────────

local _filter = ""
local _cursor = 1
local _bufs = {}
local _wins = {}
local ns = vim.api.nvim_create_namespace("ai_model_picker")

local function filter_models(query)
	if query == "" then
		local indices = {}
		for i = 1, #M.models do
			indices[i] = i
		end
		return M.models, indices
	end
	local q = query:lower()
	local results, indices = {}, {}
	for i, m in ipairs(M.models) do
		if m.name:lower():find(q, 1, true)
			or m.id:lower():find(q, 1, true)
			or m.desc:lower():find(q, 1, true)
		then
			table.insert(results, m)
			table.insert(indices, i)
		end
	end
	return results, indices
end

local function is_current(original_idx)
	return original_idx == M._current_idx
end

local function close_picker()
	for _, w in pairs(_wins) do
		if vim.api.nvim_win_is_valid(w) then
			pcall(vim.api.nvim_win_close, w, true)
		end
	end
	for _, b in pairs(_bufs) do
		if vim.api.nvim_buf_is_valid(b) then
			pcall(vim.api.nvim_buf_delete, b, { force = true })
		end
	end
	_wins = {}
	_bufs = {}
	_filter = ""
	_cursor = 1
end

-- ── Rendering ───────────────────────────────────────────────────────

local function render_results()
	local buf = _bufs.results
	if not buf or not vim.api.nvim_buf_is_valid(buf) then
		return
	end

	local filtered, indices = filter_models(_filter)
	local lines = {}
	local hl_marks = {}

	for i, m in ipairs(filtered) do
		local active = is_current(indices[i]) and " ● " or "   "
		local is_free = m.id:find(":free") ~= nil or m.id == "openrouter/free"
		local badge = is_free and " 🆓" or " 💎"
		local icon = m.icon and (m.icon .. " ") or ""
		local line = string.format("%s%s%-28s %s%s", active, icon, m.name, m.desc, badge)
		table.insert(lines, line)

		table.insert(hl_marks, {
			line_idx = i - 1,
			is_active = is_current(indices[i]),
			name_start = #active + #icon,
			name_end = #active + #icon + 28,
			desc_start = #active + #icon + 29,
			desc_end = #line - #badge,
			is_free = is_free,
			badge_start = #line - #badge,
			badge_end = #line,
		})
	end

	if #lines == 0 then
		lines = { "  No free models matching '" .. _filter .. "'" }
		hl_marks = {}
	end

	vim.bo[buf].modifiable = true
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false

	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
	for _, h in ipairs(hl_marks) do
		if h.is_active then
			vim.api.nvim_buf_add_highlight(buf, ns, "AiPickerCurrent", h.line_idx, 0, 5)
		end
		vim.api.nvim_buf_add_highlight(buf, ns, "AiPickerModelName", h.line_idx, h.name_start, h.name_end)
		vim.api.nvim_buf_add_highlight(buf, ns, "AiPickerModelDesc", h.line_idx, h.desc_start, h.desc_end)
		local badge_hl = h.is_free and "AiPickerFree" or "AiPickerPremium"
		vim.api.nvim_buf_add_highlight(buf, ns, badge_hl, h.line_idx, h.badge_start, h.badge_end)
	end

	if _cursor > #filtered then
		_cursor = math.max(1, #filtered)
	end
	if _cursor < 1 then
		_cursor = 1
	end

	if _wins.results and vim.api.nvim_win_is_valid(_wins.results) and #filtered > 0 then
		pcall(vim.api.nvim_win_set_cursor, _wins.results, { _cursor, 0 })
	end
end

local function render_preview()
	local buf = _bufs.preview
	if not buf or not vim.api.nvim_buf_is_valid(buf) then
		return
	end

	local filtered, indices = filter_models(_filter)
	local m = filtered[_cursor]
	local orig_idx = indices and indices[_cursor]

	vim.bo[buf].modifiable = true

	if not m then
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "", "  No free model selected" })
		vim.bo[buf].modifiable = false
		return
	end

	local active_text = is_current(orig_idx) and "● ACTIVE (In Use)" or "○ Inactive"
	local tier_text = "Free Tier (Verified OpenRouter Free Endpoint)"

	local lines = {
		"",
		"  " .. (m.icon or "🤖") .. "  " .. m.name,
		"",
		"  Status:       " .. active_text,
		"  Tier:         " .. tier_text,
		"  Adapter:      openrouter (HTTP)",
		"",
		"  ── OpenRouter Free Model Slug ──────────",
		"  " .. m.id,
		"",
		"  ── Description ─────────────────────────",
		"  " .. m.desc,
		"",
		"  ── Formats & Scope ─────────────────────",
		"  • Chat Buffer     (<leader>ic / :CodeCompanionChat)",
		"  • Inline Prompt   (<leader>ii / :CodeCompanion)",
		"  • Code Actions    (<leader>if, <leader>ie, etc.)",
		"  • Command Mode    (:CodeCompanionCmd)",
		"",
		"  ── Controls ────────────────────────────",
		"  <CR> / l   : Select & apply to all formats",
		"  / / i      : Live search filter",
		"  j / k      : Navigate list",
		"  q / <Esc>  : Close picker",
	}

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false

	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
	vim.api.nvim_buf_add_highlight(buf, ns, "AiPickerModelName", 1, 0, -1)
	vim.api.nvim_buf_add_highlight(buf, ns, is_current(orig_idx) and "AiPickerCurrent" or "AiPickerModelDesc", 3, 16, -1)
	vim.api.nvim_buf_add_highlight(buf, ns, "AiPickerFree", 4, 16, -1)
	vim.api.nvim_buf_add_highlight(buf, ns, "AiPickerPreviewKey", 3, 2, 16)
	vim.api.nvim_buf_add_highlight(buf, ns, "AiPickerPreviewKey", 4, 2, 16)
	vim.api.nvim_buf_add_highlight(buf, ns, "AiPickerPreviewKey", 5, 2, 16)
	vim.api.nvim_buf_add_highlight(buf, ns, "AiPickerPreviewKey", 7, 0, -1)
	vim.api.nvim_buf_add_highlight(buf, ns, "AiPickerPreviewVal", 8, 2, -1)
	vim.api.nvim_buf_add_highlight(buf, ns, "AiPickerPreviewKey", 10, 0, -1)
	vim.api.nvim_buf_add_highlight(buf, ns, "AiPickerPreviewVal", 11, 2, -1)
	vim.api.nvim_buf_add_highlight(buf, ns, "AiPickerPreviewKey", 13, 0, -1)
	vim.api.nvim_buf_add_highlight(buf, ns, "AiPickerPreviewKey", 19, 0, -1)
end

local function render_prompt()
	local buf = _bufs.prompt
	if not buf or not vim.api.nvim_buf_is_valid(buf) then
		return
	end

	vim.bo[buf].modifiable = true
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { " " .. _filter })
	vim.bo[buf].modifiable = false

	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
	vim.api.nvim_buf_add_highlight(buf, ns, "AiPickerPromptPrefix", 0, 0, 3)
end

-- ── Selection Action ────────────────────────────────────────────────

local function select_current()
	local filtered, indices = filter_models(_filter)
	local m = filtered[_cursor]
	local orig_idx = indices and indices[_cursor]
	if not m or not orig_idx then
		return
	end

	M._current_idx = orig_idx
	M.apply_model(m)
	close_picker()
end

local function move_cursor(delta)
	local filtered = filter_models(_filter)
	if #filtered == 0 then
		return
	end
	_cursor = _cursor + delta
	if _cursor < 1 then
		_cursor = #filtered
	end
	if _cursor > #filtered then
		_cursor = 1
	end
	render_results()
	render_preview()
end

-- ── Filter / Search Input ───────────────────────────────────────────

local function start_filter()
	local buf = _bufs.prompt
	if not buf or not vim.api.nvim_buf_is_valid(buf) then
		return
	end

	vim.bo[buf].modifiable = true
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { " " .. _filter })

	if _wins.prompt and vim.api.nvim_win_is_valid(_wins.prompt) then
		vim.api.nvim_set_current_win(_wins.prompt)
		local col = 3 + #_filter
		pcall(vim.api.nvim_win_set_cursor, _wins.prompt, { 1, col })
		vim.cmd("startinsert!")

		local group = vim.api.nvim_create_augroup("AiPickerLiveFilter", { clear = true })
		vim.api.nvim_create_autocmd({ "TextChangedI", "TextChanged" }, {
			group = group,
			buffer = buf,
			callback = function()
				local line = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] or ""
				local text = line:gsub("^%s*", "")
				if text:sub(1, #"") == "" then
					text = text:sub(#"" + 1)
				end
				_filter = vim.trim(text)
				_cursor = 1
				render_results()
				render_preview()
			end,
		})

		local function stop_filter()
			vim.cmd("stopinsert")
			vim.bo[buf].modifiable = false
			pcall(vim.api.nvim_del_augroup_by_name, "AiPickerLiveFilter")
			if _wins.results and vim.api.nvim_win_is_valid(_wins.results) then
				vim.api.nvim_set_current_win(_wins.results)
			end
		end

		vim.keymap.set("i", "<Esc>", stop_filter, { buffer = buf, nowait = true })
		vim.keymap.set("i", "<CR>", function()
			stop_filter()
			local filtered = filter_models(_filter)
			if #filtered == 1 then
				_cursor = 1
				select_current()
			end
		end, { buffer = buf, nowait = true })
		vim.keymap.set("i", "<C-c>", stop_filter, { buffer = buf, nowait = true })
	end
end

-- ── Keymaps Setup ───────────────────────────────────────────────────

local function setup_keymaps(buf)
	local opts = { buffer = buf, nowait = true, silent = true }

	vim.keymap.set("n", "j", function() move_cursor(1) end, opts)
	vim.keymap.set("n", "k", function() move_cursor(-1) end, opts)
	vim.keymap.set("n", "<C-j>", function() move_cursor(1) end, opts)
	vim.keymap.set("n", "<C-k>", function() move_cursor(-1) end, opts)
	vim.keymap.set("n", "<Down>", function() move_cursor(1) end, opts)
	vim.keymap.set("n", "<Up>", function() move_cursor(-1) end, opts)
	vim.keymap.set("n", "<CR>", select_current, opts)
	vim.keymap.set("n", "<C-y>", select_current, opts)
	vim.keymap.set("n", "l", select_current, opts)
	vim.keymap.set("n", "/", start_filter, opts)
	vim.keymap.set("n", "i", start_filter, opts)
	vim.keymap.set("n", "q", close_picker, opts)
	vim.keymap.set("n", "<Esc>", close_picker, opts)
	vim.keymap.set("n", "<C-c>", close_picker, opts)
end

-- ── Main Open Entrypoint ────────────────────────────────────────────

function M.open()
	if _wins.results and vim.api.nvim_win_is_valid(_wins.results) then
		close_picker()
		return
	end

	-- Reload persisted model if needed
	M.load_persisted_model()

	local ui = vim.api.nvim_list_uis()[1] or { width = 120, height = 40 }
	local total_width = math.floor(ui.width * 0.82)
	local total_height = math.floor(ui.height * 0.72)
	local start_row = math.floor((ui.height - total_height) / 2) - 1
	local start_col = math.floor((ui.width - total_width) / 2)

	local prompt_height = 1
	local results_width = math.floor(total_width * 0.48)
	local preview_width = total_width - results_width - 1
	local results_height = total_height - prompt_height - 2

	-- 1. Prompt Window
	local prompt_buf = vim.api.nvim_create_buf(false, true)
	vim.bo[prompt_buf].bufhidden = "wipe"
	vim.bo[prompt_buf].buftype = "nofile"
	local prompt_win = vim.api.nvim_open_win(prompt_buf, false, {
		relative = "editor",
		row = start_row,
		col = start_col,
		width = results_width,
		height = prompt_height,
		style = "minimal",
		border = "rounded",
		title = " 🔍 Filter Free Models (/ or i to type) ",
		title_pos = "center",
		zindex = 60,
	})
	vim.wo[prompt_win].cursorline = false
	vim.wo[prompt_win].winhighlight = "Normal:AiPickerNormal,FloatBorder:AiPickerBorder,FloatTitle:AiPickerTitle"

	-- 2. Results Window (Focused)
	local results_buf = vim.api.nvim_create_buf(false, true)
	vim.bo[results_buf].bufhidden = "wipe"
	vim.bo[results_buf].buftype = "nofile"
	local results_win = vim.api.nvim_open_win(results_buf, true, {
		relative = "editor",
		row = start_row + prompt_height + 2,
		col = start_col,
		width = results_width,
		height = results_height,
		style = "minimal",
		border = "rounded",
		title = " 🆓 Active Free Models (<CR> to select) ",
		title_pos = "center",
		zindex = 60,
	})
	vim.wo[results_win].cursorline = true
	vim.wo[results_win].winhighlight = "Normal:AiPickerNormal,FloatBorder:AiPickerBorder,FloatTitle:AiPickerResultTitle,CursorLine:AiPickerSelection"

	-- 3. Preview Window
	local preview_buf = vim.api.nvim_create_buf(false, true)
	vim.bo[preview_buf].bufhidden = "wipe"
	vim.bo[preview_buf].buftype = "nofile"
	local preview_win = vim.api.nvim_open_win(preview_buf, false, {
		relative = "editor",
		row = start_row,
		col = start_col + results_width + 2,
		width = preview_width,
		height = total_height,
		style = "minimal",
		border = "rounded",
		title = " 📋 Free Model Preview ",
		title_pos = "center",
		zindex = 60,
	})
	vim.wo[preview_win].cursorline = false
	vim.wo[preview_win].wrap = true
	vim.wo[preview_win].winhighlight = "Normal:AiPickerNormal,FloatBorder:AiPickerBorder,FloatTitle:AiPickerPreviewTitle"

	_bufs = { results = results_buf, prompt = prompt_buf, preview = preview_buf }
	_wins = { results = results_win, prompt = prompt_win, preview = preview_win }

	setup_keymaps(results_buf)

	_filter = ""
	_cursor = M._current_idx or 1

	render_prompt()
	render_results()
	render_preview()

	-- Auto-close when moving focus away
	vim.api.nvim_create_autocmd("WinLeave", {
		callback = function()
			vim.defer_fn(function()
				local cur = vim.api.nvim_get_current_win()
				local is_our_window = cur == _wins.results or cur == _wins.prompt or cur == _wins.preview
				if not is_our_window then
					close_picker()
				end
			end, 100)
		end,
		once = true,
	})
end

vim.api.nvim_create_user_command("AIModels", function()
	M.open()
end, { desc = "Open CodeCompanion free AI model selector" })

return M
