local M = {}

local NOTE_VAR = "filescope_note"

local defaults = {
	direction = "right", -- "left" | "right" | "top" | "bottom" (aliases: "up", "down")
	size = 0.5,
	close_buffer = true,
}

local config = vim.deepcopy(defaults)

local DIRECTION_ALIASES = {
	up = "top",
	down = "bottom",
}

local DIRECTION_CMDS = {
	left = "leftabove vsplit",
	right = "rightbelow vsplit",
	top = "leftabove split",
	bottom = "rightbelow split",
}

local function normalize_direction(direction)
	direction = DIRECTION_ALIASES[direction] or direction
	if DIRECTION_CMDS[direction] then
		return direction
	end
	return "right"
end

local function get_current_file()
	local file = vim.api.nvim_buf_get_name(0)
	if file == "" then
		return nil
	end
	return vim.fn.fnamemodify(file, ":p")
end

local function get_repo_root(file)
	return vim.fs.root(file, { ".git" }) or vim.fn.getcwd()
end

local function get_note_path(file)
	local root = get_repo_root(file)
	local relative = vim.fs.relpath(root, file)
	if not relative then
		return nil
	end
	return root .. "/.filescope/" .. relative .. ".md"
end

local function list_all_wins()
	local wins = {}
	for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
		for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
			wins[#wins + 1] = win
		end
	end
	return wins
end

local function find_note_wins()
	local found = {}
	for _, win in ipairs(list_all_wins()) do
		if vim.api.nvim_win_is_valid(win) then
			local buf = vim.api.nvim_win_get_buf(win)
			local ok, value = pcall(vim.api.nvim_buf_get_var, buf, NOTE_VAR)
			if ok and value then
				found[#found + 1] = { win = win, buf = buf }
			end
		end
	end
	return found
end

local function close_note(opts)
	local found = find_note_wins()
	if #found == 0 then
		return false
	end

	for _, entry in ipairs(found) do
		if vim.api.nvim_win_is_valid(entry.win) then
			vim.api.nvim_win_close(entry.win, true)
		end
	end

	if opts.close_buffer then
		for _, entry in ipairs(found) do
			if vim.api.nvim_buf_is_valid(entry.buf) then
				if vim.bo[entry.buf].modified then
					vim.notify("FileScope: note has unsaved changes, buffer kept open", vim.log.levels.WARN)
				else
					pcall(vim.api.nvim_buf_delete, entry.buf, { force = false })
				end
			end
		end
	end

	return true
end

local function open_note(path, opts)
	local direction = normalize_direction(opts.direction)
	vim.cmd(DIRECTION_CMDS[direction] .. " " .. vim.fn.fnameescape(path))

	local win = vim.api.nvim_get_current_win()
	if direction == "left" or direction == "right" then
		vim.api.nvim_win_set_width(win, math.floor(vim.o.columns * opts.size))
	else
		vim.api.nvim_win_set_height(win, math.floor(vim.o.lines * opts.size))
	end
end

function M.toggle(opts)
	opts = vim.tbl_deep_extend("force", config, opts or {})

	if close_note(opts) then
		return
	end

	local file = get_current_file()
	if not file then
		vim.notify("FileScope: current buffer has no file", vim.log.levels.WARN)
		return
	end

	if file:find("/%.filescope/") then
		vim.notify("FileScope: already inside .filescope", vim.log.levels.WARN)
		return
	end

	local note = get_note_path(file)
	if not note then
		vim.notify("FileScope: could not determine note path", vim.log.levels.ERROR)
		return
	end

	vim.fn.mkdir(vim.fn.fnamemodify(note, ":h"), "p")

	open_note(note, opts)

	local note_buf = vim.api.nvim_get_current_buf()
	vim.api.nvim_buf_set_var(note_buf, NOTE_VAR, true)
	vim.bo[note_buf].filetype = "markdown"
end

function M.setup(opts)
	config = vim.tbl_deep_extend("force", defaults, opts or {})

	vim.api.nvim_create_user_command("FileScope", function(cmd_opts)
		local direction = cmd_opts.args ~= "" and cmd_opts.args or nil
		M.toggle({ direction = direction })
	end, {
		nargs = "?",
		complete = function()
			return { "left", "right", "top", "bottom" }
		end,
	})
end

return M
