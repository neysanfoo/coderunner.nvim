local M = {}

function M.setup(config)
	-- Define a local variable to store the output window ID and buffer number
	local output_win_buf = { winid = nil, bufnr = nil }

	-- Helper function to escape paths for shell
	local function shell_escape(path)
		return path:gsub("\\", "/") -- Convert Windows paths to Unix style
	end

	vim.api.nvim_create_user_command("Run", function()
		-- Clean up previous window and buffer
		if output_win_buf.winid and vim.api.nvim_win_is_valid(output_win_buf.winid) then
			vim.api.nvim_win_close(output_win_buf.winid, true)
			output_win_buf.winid = nil
		end

		if output_win_buf.bufnr and vim.api.nvim_buf_is_valid(output_win_buf.bufnr) then
			vim.api.nvim_buf_delete(output_win_buf.bufnr, { force = true })
			output_win_buf.bufnr = nil
		end

		-- Get current buffer info first
		local current_buf = vim.api.nvim_get_current_buf()
		local filetype = vim.api.nvim_buf_get_option(current_buf, "filetype")
		local command = config.filetype_commands[filetype]

		if not command then
			print("Unsupported filetype: " .. filetype)
			return
		end

		-- Get file information
		local filename = vim.api.nvim_buf_get_name(current_buf)
		local dir = shell_escape(vim.fn.fnamemodify(filename, ":p:h"))
		local fileNameWithoutExt = shell_escape(vim.fn.fnamemodify(filename, ":p:t:r"))
		local fullFilePath = shell_escape(vim.fn.fnamemodify(filename, ":p"))

		-- Process command
		local final_command
		if type(command) == "table" then
			local processed_commands = {}
			for _, cmd in ipairs(command) do
				local processed_cmd = cmd:gsub("$dir", dir)
					:gsub("$fullFilePath", fullFilePath)
					:gsub("$fileNameWithoutExt", fileNameWithoutExt)
				table.insert(processed_commands, processed_cmd)
			end
			final_command = table.concat(processed_commands, " && ")
		else
			final_command = command
				:gsub("$dir", dir)
				:gsub("$fullFilePath", fullFilePath)
				:gsub("$fileNameWithoutExt", fileNameWithoutExt)
		end

		-- Debug line
		-- print(final_command)

		-- Create new terminal window
		local height = vim.api.nvim_get_option("lines")
		local split_size = math.min(config.buffer_height, height)
		local current_win = vim.api.nvim_get_current_win()

		vim.cmd(split_size .. "new")
		local output_win = vim.api.nvim_get_current_win()

		-- Run the command
		vim.fn.termopen(final_command)
		local output_bufnr = vim.api.nvim_win_get_buf(output_win)

		-- Store window and buffer info
		output_win_buf.winid = output_win
		output_win_buf.bufnr = output_bufnr

		-- Set up terminal mappings
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
