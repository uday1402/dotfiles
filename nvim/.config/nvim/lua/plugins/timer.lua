local M = {}

local uv = vim.uv or vim.loop
local history_file = vim.fn.stdpath("data") .. "/timer_history.json"
local namespace = vim.api.nvim_create_namespace("UserTimerDashboard")

local state = {
	mode = nil,
	duration = 0,
	elapsed = 0,
	started_at = nil,
	paused = false,
	ticker = nil,
	buf = nil,
	win = nil,
	stats_period = "daily",
	stats_offset = 0,
}

local function now()
	return uv.hrtime() / 1e9
end

local function current_elapsed()
	if not state.mode then
		return 0
	end
	return state.elapsed + (state.started_at and (now() - state.started_at) or 0)
end

local function format_time(seconds)
	seconds = math.max(0, math.floor(seconds + 0.5))
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	local secs = seconds % 60
	return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

local function displayed_seconds()
	local elapsed = current_elapsed()
	if state.mode == "countdown" then
		return math.max(0, state.duration - elapsed)
	end
	return elapsed
end

local function parse_duration(value)
	if not value then
		return nil
	end
	value = vim.trim(value:lower())
	if value == "" then
		return nil
	end

	if value:match("^%d+:%d%d?:%d%d?$") then
		local h, m, s = value:match("^(%d+):(%d%d?):(%d%d?)$")
		m, s = tonumber(m), tonumber(s)
		if m < 60 and s < 60 then
			return tonumber(h) * 3600 + m * 60 + s
		end
	elseif value:match("^%d+:%d%d?$") then
		local m, s = value:match("^(%d+):(%d%d?)$")
		s = tonumber(s)
		if s < 60 then
			return tonumber(m) * 60 + s
		end
	elseif value:match("^%d+%.?%d*$") then
		return tonumber(value)
	end

	local total, matched = 0, ""
	for amount, unit in value:gmatch("(%d+%.?%d*)%s*([hms])") do
		local multiplier = unit == "h" and 3600 or unit == "m" and 60 or 1
		total = total + tonumber(amount) * multiplier
		matched = matched .. amount .. unit
	end
	local compact = value:gsub("%s+", "")
	if total > 0 and matched == compact then
		return total
	end
	return nil
end

local function read_history()
	local ok, lines = pcall(vim.fn.readfile, history_file)
	if not ok or #lines == 0 then
		return {}
	end
	local decoded_ok, data = pcall(vim.json.decode, table.concat(lines, "\n"))
	return decoded_ok and type(data) == "table" and data or {}
end

local function write_history(history)
	vim.fn.mkdir(vim.fn.fnamemodify(history_file, ":h"), "p")
	local ok, encoded = pcall(vim.json.encode, history)
	if ok then
		pcall(vim.fn.writefile, { encoded }, history_file)
	end
end

local function ist_timestamp()
	return os.date("!%Y-%m-%dT%H:%M:%S", os.time() + 19800) .. "+05:30"
end

local function display_timestamp(timestamp)
	if type(timestamp) ~= "string" then
		return "Unknown time"
	end
	local year, month, day, hour, minute = timestamp:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)T(%d%d):(%d%d).-%+05:30$")
	if year then
		return string.format("%s-%s-%s  %s:%s IST", day, month, year, hour, minute)
	end
	year, month, day, hour, minute = timestamp:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)T(%d%d):(%d%d).-[Zz]$")
	if year then
		local converted = os.time({
			year = tonumber(year),
			month = tonumber(month),
			day = tonumber(day),
			hour = tonumber(hour),
			min = tonumber(minute),
			sec = 0,
		}) + 19800
		return os.date("%d-%m-%Y  %H:%M IST", converted)
	end
	return timestamp
end

local function save_session(reason)
	if not state.mode then
		return
	end
	local elapsed = current_elapsed()
	local history = read_history()
	table.insert(history, 1, {
		mode = state.mode,
		duration = state.duration,
		elapsed = math.floor(elapsed + 0.5),
		completed = reason == "completed",
		ended_at = ist_timestamp(),
	})
	write_history(history)
end

local function close_ticker()
	if state.ticker then
		state.ticker:stop()
		state.ticker:close()
		state.ticker = nil
	end
end

local function clear_state()
	close_ticker()
	state.mode = nil
	state.duration = 0
	state.elapsed = 0
	state.started_at = nil
	state.paused = false
	vim.cmd("redrawstatus")
end

local function statistics(history)
	local result = { total = #history, seconds = 0, countdowns = 0, stopwatches = 0, completed = 0 }
	for _, item in ipairs(history) do
		result.seconds = result.seconds + (tonumber(item.elapsed) or 0)
		if item.mode == "countdown" then
			result.countdowns = result.countdowns + 1
		else
			result.stopwatches = result.stopwatches + 1
		end
		if item.completed then
			result.completed = result.completed + 1
		end
	end
	return result
end

local function timestamp_epoch(timestamp)
	if type(timestamp) ~= "string" then
		return nil
	end
	local y, m, d, h, min, sec = timestamp:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)T(%d%d):(%d%d):(%d%d)%+05:30$")
	if y then
		return os.time({ year = y, month = m, day = d, hour = h, min = min, sec = sec })
	end
	y, m, d, h, min, sec = timestamp:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)T(%d%d):(%d%d):(%d%d)[Zz]$")
	if y then
		return os.time({ year = y, month = m, day = d, hour = h, min = min, sec = sec }) + 19800
	end
	return nil
end

local function selected_period()
	if state.stats_period == "all" then
		return nil, nil, "All time"
	end
	local today = os.date("*t")
	local start
	if state.stats_period == "daily" then
		start = os.time({ year = today.year, month = today.month, day = today.day + state.stats_offset, hour = 0 })
	elseif state.stats_period == "weekly" then
		local monday_delta = (today.wday + 5) % 7
		start = os.time({
			year = today.year,
			month = today.month,
			day = today.day - monday_delta + state.stats_offset * 7,
			hour = 0,
		})
	else
		start = os.time({ year = today.year, month = today.month + state.stats_offset, day = 1, hour = 0 })
	end
	local finish
	if state.stats_period == "daily" then
		finish = os.time({
			year = os.date("*t", start).year,
			month = os.date("*t", start).month,
			day = os.date("*t", start).day + 1,
			hour = 0,
		})
	elseif state.stats_period == "weekly" then
		finish = start + 7 * 86400
	else
		local parts = os.date("*t", start)
		finish = os.time({ year = parts.year, month = parts.month + 1, day = 1, hour = 0 })
	end
	local label = state.stats_period == "daily" and os.date("%d %b %Y", start)
		or state.stats_period == "weekly" and (os.date("%d %b", start) .. " – " .. os.date("%d %b %Y", finish - 1))
		or os.date("%B %Y", start)
	return start, finish, label
end

local function period_history(history)
	local start, finish, label = selected_period()
	if not start then
		return history, label
	end
	local filtered = {}
	for _, item in ipairs(history) do
		local ended = timestamp_epoch(item.ended_at)
		if ended and ended >= start and ended < finish then
			table.insert(filtered, item)
		end
	end
	return filtered, label
end

local render

local function finish_countdown()
	save_session("completed")
	clear_state()
	if render then
		render()
	end
	vim.notify("Time is up!", vim.log.levels.INFO, { title = "Timer" })
end

local function start_ticker()
	close_ticker()
	state.ticker = uv.new_timer()
	state.ticker:start(
		0,
		250,
		vim.schedule_wrap(function()
			if state.mode == "countdown" and displayed_seconds() <= 0 then
				finish_countdown()
				return
			end
			vim.cmd("redrawstatus")
			if render then
				render()
			end
		end)
	)
end

local function begin(mode, duration)
	if state.mode then
		save_session("replaced")
	end
	clear_state()
	state.mode = mode
	state.duration = duration or 0
	state.started_at = now()
	start_ticker()
	vim.cmd("redrawstatus")
	if render then
		render()
	end
end

function M.start_countdown(value)
	local seconds = type(value) == "number" and value or parse_duration(value)
	if not seconds or seconds <= 0 then
		vim.notify("Invalid time. Try 90, 05:00, 1h30m, or 45s.", vim.log.levels.ERROR, { title = "Timer" })
		return
	end
	begin("countdown", seconds)
end

function M.start_stopwatch()
	begin("stopwatch", 0)
end

function M.pause()
	if not state.mode or state.paused then
		return
	end
	state.elapsed = current_elapsed()
	state.started_at = nil
	state.paused = true
	close_ticker()
	vim.cmd("redrawstatus")
	if render then
		render()
	end
end

function M.resume()
	if not state.mode or not state.paused then
		return
	end
	state.started_at = now()
	state.paused = false
	start_ticker()
end

function M.toggle_pause()
	if state.paused then
		M.resume()
	else
		M.pause()
	end
end

function M.stop()
	if not state.mode then
		return
	end
	save_session("stopped")
	clear_state()
	if render then
		render()
	end
end

function M.reset()
	if not state.mode then
		return
	end
	state.elapsed = 0
	state.started_at = state.paused and nil or now()
	if render then
		render()
	end
end

function M.statusline()
	if not state.mode then
		return ""
	end
	local icon = state.mode == "countdown" and "󰔛" or "󱎫"
	local paused = state.paused and " 󰏤" or ""
	return string.format("%s %s%s", icon, format_time(displayed_seconds()), paused)
end

function M.is_active()
	return state.mode ~= nil
end

function M.clear_history(force)
	local function clear()
		write_history({})
		if render then
			render()
		end
		vim.notify("Timer history cleared", vim.log.levels.INFO, { title = "Timer" })
	end
	if force then
		clear()
		return
	end
	vim.ui.select({ "Cancel", "Clear all history" }, { prompt = "Delete every saved timer session?" }, function(choice)
		if choice == "Clear all history" then
			clear()
		end
	end)
end

local function set_countdown_from_input()
	vim.ui.input({ prompt = "Countdown (25m, 1h30m, 05:00, or seconds): " }, function(value)
		if value then
			M.start_countdown(value)
		end
	end)
end

function M.set_stats_period(period)
	if not vim.tbl_contains({ "daily", "weekly", "monthly", "all" }, period) then
		vim.notify(
			"Statistics period must be daily, weekly, monthly, or all",
			vim.log.levels.ERROR,
			{ title = "Timer" }
		)
		return
	end
	state.stats_period = period
	state.stats_offset = 0
	if render then
		render()
	end
end

function M.move_stats_period(direction)
	if state.stats_period == "all" then
		return
	end
	state.stats_offset = state.stats_offset + direction
	if state.stats_offset > 0 then
		state.stats_offset = 0
	end
	if render then
		render()
	end
end

local function valid_window()
	return state.win and vim.api.nvim_win_is_valid(state.win) and state.buf and vim.api.nvim_buf_is_valid(state.buf)
end

render = function()
	if not valid_window() then
		return
	end
	local history = read_history()
	local visible_history, period_label = period_history(history)
	local stats = statistics(visible_history)
	local timer_text = state.mode and format_time(displayed_seconds()) or "00:00:00"
	local mode_text = state.mode and (state.mode == "countdown" and "COUNTDOWN" or "STOPWATCH") or "NO ACTIVE TIMER"
	local activity = state.paused and "PAUSED" or (state.mode and "RUNNING" or "READY")
	local function centered(text)
		local width = vim.api.nvim_win_get_width(state.win)
		return string.rep(" ", math.max(0, math.floor((width - vim.fn.strdisplaywidth(text)) / 2))) .. text
	end
	local box_width = math.min(66, vim.api.nvim_win_get_width(state.win) - 6)
	local box_indent =
		string.rep(" ", math.max(0, math.floor((vim.api.nvim_win_get_width(state.win) - box_width - 2) / 2)))
	local function box_row(text, align)
		local text_width = vim.fn.strdisplaywidth(text)
		local available = math.max(0, box_width - text_width)
		local left = align == "center" and math.floor(available / 2) or 2
		left = math.min(left, available)
		return box_indent .. "│" .. string.rep(" ", left) .. text .. string.rep(" ", available - left) .. "│"
	end
	local lines = {
		"",
		centered(mode_text .. "  •  " .. activity),
		centered(timer_text),
		"",
		"  ──────────────────────────────────────────────────────────────────",
		"",
		"   c Countdown   w Stopwatch   p Pause   r Reset   s Stop",
		"",
		box_indent .. "╭" .. string.rep("─", box_width) .. "╮",
		box_row("1 Day   2 Week   3 Month   4 All   [ Previous   ] Next", "center"),
		"",
		box_row(period_label, "center"),
		"",
		box_row(
			string.format(
				"%d sessions    %s tracked    %d completed",
				stats.total,
				format_time(stats.seconds),
				stats.completed
			),
			"center"
		),
		box_row(string.format("%d countdowns  ·  %d stopwatches", stats.countdowns, stats.stopwatches), "center"),
		box_indent .. "╰" .. string.rep("─", box_width) .. "╯",
		"",
		"  SESSIONS                                                     IST",
	}
	if #visible_history == 0 then
		table.insert(lines, "  No sessions in this period")
	else
		for i = 1, math.min(7, #visible_history) do
			local item = visible_history[i]
			local stamp = display_timestamp(item.ended_at)
			local mark = item.completed and "✓" or "·"
			local label = item.mode == "countdown" and "Countdown" or "Stopwatch"
			table.insert(
				lines,
				string.format("  %s  %-11s  %s    %s", mark, label, format_time(item.elapsed or 0), stamp)
			)
		end
	end
	vim.bo[state.buf].modifiable = true
	vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
	vim.bo[state.buf].modifiable = false
	vim.api.nvim_buf_clear_namespace(state.buf, namespace, 0, -1)
	vim.api.nvim_buf_add_highlight(state.buf, namespace, "TimerMuted", 1, 0, -1)
	vim.api.nvim_buf_add_highlight(state.buf, namespace, "TimerClock", 2, 0, -1)
	vim.api.nvim_buf_add_highlight(state.buf, namespace, "TimerAccent", 8, 0, -1)
	vim.api.nvim_buf_add_highlight(state.buf, namespace, "TimerDate", 10, 0, -1)
	vim.api.nvim_buf_add_highlight(state.buf, namespace, "TimerAccent", 15, 0, -1)
end

function M.open()
	if valid_window() then
		vim.api.nvim_set_current_win(state.win)
		return
	end
	local width = math.min(74, math.max(44, vim.o.columns - 8))
	local height = math.min(24, math.max(18, vim.o.lines - 6))
	state.buf = vim.api.nvim_create_buf(false, true)
	state.win = vim.api.nvim_open_win(state.buf, true, {
		relative = "editor",
		width = width,
		height = height,
		col = math.floor((vim.o.columns - width) / 2),
		row = math.floor((vim.o.lines - height) / 2 - 1),
		style = "minimal",
		border = "rounded",
		title = " 󰔛 Timer ",
		title_pos = "center",
	})
	vim.bo[state.buf].bufhidden = "wipe"
	vim.bo[state.buf].filetype = "timer"
	vim.wo[state.win].cursorline = false
	vim.wo[state.win].winhighlight = "Normal:NormalFloat,FloatBorder:TimerBorder"

	local function map(key, action, description)
		vim.keymap.set("n", key, action, { buffer = state.buf, silent = true, nowait = true, desc = description })
	end
	map("c", set_countdown_from_input, "Start countdown")
	map("w", M.start_stopwatch, "Start stopwatch")
	map("p", M.toggle_pause, "Pause or resume timer")
	map("r", M.reset, "Reset timer")
	map("s", M.stop, "Stop and save timer")
	map("d", M.clear_history, "Clear timer history")
	map("1", function()
		M.set_stats_period("daily")
	end, "Daily statistics")
	map("2", function()
		M.set_stats_period("weekly")
	end, "Weekly statistics")
	map("3", function()
		M.set_stats_period("monthly")
	end, "Monthly statistics")
	map("4", function()
		M.set_stats_period("all")
	end, "All-time statistics")
	map("[", function()
		M.move_stats_period(-1)
	end, "Previous statistics period")
	map("]", function()
		M.move_stats_period(1)
	end, "Next statistics period")
	map("q", function()
		if valid_window() then
			vim.api.nvim_win_close(state.win, true)
		end
	end, "Close timer")
	map("<Esc>", function()
		if valid_window() then
			vim.api.nvim_win_close(state.win, true)
		end
	end, "Close timer")
	vim.api.nvim_create_autocmd("BufWipeout", {
		buffer = state.buf,
		once = true,
		callback = function()
			state.buf, state.win = nil, nil
		end,
	})
	render()
end

function M.toggle()
	if valid_window() then
		vim.api.nvim_win_close(state.win, true)
	else
		M.open()
	end
end

function M.setup()
	vim.api.nvim_set_hl(0, "TimerClock", { link = "Title", default = true })
	vim.api.nvim_set_hl(0, "TimerAccent", { link = "Special", default = true })
	vim.api.nvim_set_hl(0, "TimerDate", { bold = true, default = true })
	vim.api.nvim_set_hl(0, "TimerMuted", { link = "Comment", default = true })
	vim.api.nvim_set_hl(0, "TimerBorder", { link = "FloatBorder", default = true })
	vim.api.nvim_create_user_command("Timer", M.open, { desc = "Open timer dashboard" })
	vim.api.nvim_create_user_command("TimerCountdown", function(opts)
		if opts.args == "" then
			set_countdown_from_input()
		else
			M.start_countdown(opts.args)
		end
	end, { nargs = "?", desc = "Start a countdown" })
	vim.api.nvim_create_user_command("TimerStopwatch", M.start_stopwatch, { desc = "Start a stopwatch" })
	vim.api.nvim_create_user_command("TimerPause", M.toggle_pause, { desc = "Pause/resume timer" })
	vim.api.nvim_create_user_command("TimerStop", M.stop, { desc = "Stop and save timer" })
	vim.api.nvim_create_user_command("TimerReset", M.reset, { desc = "Reset timer" })
	vim.api.nvim_create_user_command("TimerHistory", M.open, { desc = "Open timer history and statistics" })
	vim.api.nvim_create_user_command("TimerClearHistory", function()
		M.clear_history()
	end, { desc = "Clear all timer history" })
	vim.api.nvim_create_user_command("TimerStats", function(opts)
		M.set_stats_period(opts.args)
		M.open()
	end, {
		nargs = 1,
		complete = function()
			return { "daily", "weekly", "monthly", "all" }
		end,
		desc = "Open timer statistics period",
	})
	local keymaps = {
		{ "<leader>ct", M.toggle, "Toggle timer interface" },
		{ "<leader>cc", set_countdown_from_input, "Start countdown" },
		{ "<leader>cw", M.start_stopwatch, "Start stopwatch" },
		{ "<leader>cp", M.toggle_pause, "Pause/resume timer" },
		{ "<leader>cs", M.stop, "Stop and save timer" },
		{ "<leader>cr", M.reset, "Reset timer" },
		{ "<leader>ch", M.open, "Timer history and statistics" },
		{ "<leader>cd", M.clear_history, "Clear timer history" },
		{
			"<leader>c1",
			function()
				M.set_stats_period("daily")
				M.open()
			end,
			"Daily timer statistics",
		},
		{
			"<leader>c2",
			function()
				M.set_stats_period("weekly")
				M.open()
			end,
			"Weekly timer statistics",
		},
		{
			"<leader>c3",
			function()
				M.set_stats_period("monthly")
				M.open()
			end,
			"Monthly timer statistics",
		},
		{
			"<leader>c4",
			function()
				M.set_stats_period("all")
				M.open()
			end,
			"All-time timer statistics",
		},
		{
			"<leader>c[",
			function()
				M.move_stats_period(-1)
			end,
			"Previous statistics period",
		},
		{
			"<leader>c]",
			function()
				M.move_stats_period(1)
			end,
			"Next statistics period",
		},
	}
	for _, mapping in ipairs(keymaps) do
		vim.keymap.set("n", mapping[1], mapping[2], { desc = mapping[3], silent = true })
	end

	local group = vim.api.nvim_create_augroup("UserTimer", { clear = true })
	vim.api.nvim_create_autocmd("VimLeavePre", {
		group = group,
		callback = function()
			if state.mode then
				save_session("quit")
			end
			close_ticker()
		end,
	})
end

return {
	{
		name = "timer.nvim",
		dir = vim.fn.stdpath("config"),
		lazy = false,
		init = M.setup,
	},
	{
		"nvim-lualine/lualine.nvim",
		optional = true,
		opts = function(_, opts)
			opts.sections = opts.sections or {}
			opts.sections.lualine_x = opts.sections.lualine_x or {}
			table.insert(opts.sections.lualine_x, 1, { M.statusline, cond = M.is_active })
		end,
	},
	{
		"folke/which-key.nvim",
		optional = true,
		opts = function(_, opts)
			opts.spec = opts.spec or {}
			table.insert(opts.spec, { "<leader>c", group = "[C]lock" })
		end,
	},
}
