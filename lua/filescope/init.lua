local M = {}

local NOTE_VAR = "filescope_note"

local function get_current_file()
	local file = vim.api.nvim_buf_get_name(0)

	if file == "" then
		return nil
	end

	return vim.fn.fnamemodify(file, ":p")
end

local function get_repo_root()
	return vim.fs.root(0, { ".git" }) or vim.fn.getcwd()
end

local function get_note_path(file)
	local root = get_repo_root()
	local relative = vim.fs.relpath(root, file)

	if not relative then
		return nil
	end

	return root .. "/.filescope/" .. relative .. ".md"
end

local function find_note_window()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_is_valid(win) then
			local buf = vim.api.nvim_win_get_buf(win)

			local ok, value = pcall(vim.api.nvim_buf_get_var, buf, NOTE_VAR)

			if ok and value then
				return win
			end
		end
	end

	return nil
end

local function close_note()
	local win = find_note_window()

	if not win then
		return false
	end

	vim.api.nvim_win_close(win, true)

	return true
end

function M.toggle()
	-- If a FileScope note is already open, close it.
	if close_note() then
		return
	end

	local file = get_current_file()

	if not file then
		vim.notify("FileScope: current buffer has no file", vim.log.levels.WARN)
		return
	end

	-- Don't create a note for files inside .filescope.
	if file:find("/%.filescope/") then
		vim.notify("FileScope: already inside .filescope", vim.log.levels.WARN)
		return
	end

	local note = get_note_path(file)

	if not note then
		vim.notify("FileScope: could not determine note path", vim.log.levels.ERROR)
		return
	end

	-- Create directories recursively.
	vim.fn.mkdir(vim.fn.fnamemodify(note, ":h"), "p")

	-- Open the note to the right.
	vim.cmd("vsplit " .. vim.fn.fnameescape(note))

	-- Equalize both windows to 50/50.
	vim.cmd("wincmd =")

	local note_buf = vim.api.nvim_get_current_buf()

	-- Mark this buffer as a FileScope note.
	vim.api.nvim_buf_set_var(note_buf, NOTE_VAR, true)

	-- Markdown behavior.
	vim.bo[note_buf].filetype = "markdown"
end

function M.setup()
	vim.api.nvim_create_user_command("FileScope", M.toggle, {})
end

return M
