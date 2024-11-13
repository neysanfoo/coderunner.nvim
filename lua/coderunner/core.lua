local M = {}

function M.setup(config)
	-- Define a local variable to store the output window ID and buffer number
	local output_win_buf = { winid = nil, bufnr = nil }

	-- Helper function to escape paths for shell
	local function shell_escape(path)
		return path:gsub("\\", "/") -- Convert Windows paths to Unix style
	end

	-- Function to run a command based on filetype
	local function run_filetype_command()
		local bufnr = vim.api.nvim_get_current_buf()
		local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
		local command = config.filetype_commands[filetype]
		if not command then
			print("Unsupported filetype: " .. filetype)
			return
		end

		local filename = vim.api.nvim_buf_get_name(bufnr)
		local dir = shell_escape(vim.fn.fnamemodify(filename, ":p:h"))
		local fileNameWithoutExt = shell_escape(vim.fn.fnamemodify(filename, ":p:t:r"))
		local fullFilePath = shell_escape(vim.fn.fnamemodify(filename, ":p"))

		if type(command) == "table" then
			for i, cmd in ipairs(command) do
				command[i] = cmd:gsub("$dir", dir)
					:gsub("$fullFilePath", fullFilePath)
					:gsub("$fileNameWithoutExt", fileNameWithoutExt)
			end
			command = table.concat(command, " && ")
		else
			command = command
				:gsub("$dir", dir)
				:gsub("$fullFilePath", fullFilePath)
				:gsub("$fileNameWithoutExt", fileNameWithoutExt)
		end

		-- Debug line
		print(command)
		return command
	end

	vim.api.nvim_create_user_command("Run", function()
		-- If a previous output window and buffer exists, close and delete them
		if output_win_buf.winid and output_win_buf.bufnr then
			if vim.api.nvim_win_is_valid(output_win_buf.winid) and #vim.api.nvim_tabpage_list_wins(0) > 1 then
				vim.api.nvim_win_close(output_win_buf.winid, true)
			end
			if vim.api.nvim_buf_is_valid(output_win_buf.bufnr) then
				vim.api.nvim_buf_delete(output_win_buf.bufnr, { force = true })
			end
		end

		-- Get the command to run based on the filetype
		local command = run_filetype_command()
		if not command then
			return
		end

		local height = vim.api.nvim_get_option("lines")
		local split_size = math.min(config.buffer_height, height)

		local current_win = vim.api.nvim_get_current_win()
		vim.cmd(split_size .. "new")

		local output_win = vim.api.nvim_get_current_win()
		vim.fn.termopen(command)

		local output_bufnr = vim.api.nvim_win_get_buf(output_win)

		output_win_buf.winid = output_win
		output_win_buf.bufnr = output_bufnr

		vim.api.nvim_exec(
			[[
            function! ConditionalBwipeout(cmdline)
                if (getcmdtype() == ':' && getcmdline() == 'q' && bufname('%') =~ 'term://.*')
                    return 'bwipeout'
                else
                    return a:cmdline
                endif
            endfunction
            cnoreabbrev <expr> q ConditionalBwipeout('q')
        ]],
			false
		)

		vim.api.nvim_buf_set_keymap(output_bufnr, "n", "q", ":bwipeout<CR>", { noremap = true, silent = true })

		-- Set focus back to the original window if focus_back is true
		if config.focus_back then
			vim.api.nvim_set_current_win(current_win)
		end
	end, {})
end

return M
