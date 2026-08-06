local M = {}

local data_file = vim.fn.stdpath("data") .. "/triforce_daily_lines.json"
local state = {
	date = nil,
	added = 0,
	deleted = 0,
	updated = 0,
	save_scheduled = false,
}

local function today()
	return os.date("%Y-%m-%d")
end

local function reset()
	state.date = today()
	state.added = 0
	state.deleted = 0
	state.updated = 0
end

local function save()
	vim.fn.mkdir(vim.fn.fnamemodify(data_file, ":h"), "p")
	pcall(vim.fn.writefile, {
		vim.json.encode({
			date = state.date,
			added = state.added,
			deleted = state.deleted,
			updated = state.updated,
		}),
	}, data_file)
end

local function schedule_save()
	if state.save_scheduled then
		return
	end

	state.save_scheduled = true
	vim.defer_fn(function()
		state.save_scheduled = false
		save()
	end, 1000)
end

local function ensure_today()
	if state.date ~= today() then
		reset()
		schedule_save()
	end
end

local function is_trackable(bufnr)
	return vim.api.nvim_buf_is_valid(bufnr)
		and vim.bo[bufnr].buftype == ""
		and vim.bo[bufnr].modifiable
		and not vim.bo[bufnr].binary
end

local function lines_to_string(lines)
	return table.concat(lines, "\n")
end

local function track_save(bufnr)
	if not is_trackable(bufnr) then
		return
	end

	local file = vim.api.nvim_buf_get_name(bufnr)
	local old_lines = {}
	if file ~= "" and vim.fn.filereadable(file) == 1 then
		local ok, lines = pcall(vim.fn.readfile, file)
		if not ok then
			return
		end
		old_lines = lines
	end

	local new_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local hunks = vim.diff(lines_to_string(old_lines), lines_to_string(new_lines), {
		result_type = "indices",
		algorithm = "histogram",
	})

	if #hunks == 0 then
		return
	end

	ensure_today()
	for _, hunk in ipairs(hunks) do
		local old_count = hunk[2]
		local new_count = hunk[4]
		local updated_count = math.min(old_count, new_count)

		state.updated = state.updated + updated_count
		state.added = state.added + math.max(0, new_count - old_count)
		state.deleted = state.deleted + math.max(0, old_count - new_count)
	end
	schedule_save()
end

function M.setup()
	if state.date then
		return
	end

	local ok, stored = pcall(vim.fn.readfile, data_file)
	if ok and #stored > 0 then
		local decoded_ok, data = pcall(vim.json.decode, table.concat(stored, "\n"))
		if decoded_ok and data.date == today() then
			state.date = data.date
			state.added = tonumber(data.added) or 0
			state.deleted = tonumber(data.deleted) or 0
			state.updated = tonumber(data.updated) or 0
		end
	end

	if not state.date then
		reset()
	end

	local group = vim.api.nvim_create_augroup("DailyLineCounter", { clear = true })
	vim.api.nvim_create_autocmd("BufWritePre", {
		group = group,
		callback = function(event)
			track_save(event.buf)
		end,
	})
	vim.api.nvim_create_autocmd("VimLeavePre", {
		group = group,
		callback = save,
	})
end

function M.status()
	ensure_today()
	return string.format("+%d ~%d -%d", state.added, state.updated, state.deleted)
end

return M
