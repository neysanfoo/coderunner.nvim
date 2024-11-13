local M = {}

M.config = {
	filetype_commands = {
		python = 'python3 -u "$fullFilePath"',
		lua = "lua",
		c = { 'gcc "$fullFilePath" -o "$dir/out"', '"$dir/./out"' },
		cpp = { 'g++ "$fullFilePath" -o "$dir/out"', '"$dir/./out"' },
		java = { 'javac "$fullFilePath"', 'java -cp ".:$dir" "$fileNameWithoutExt"' },
		javascript = 'node "$fullFilePath"',
		-- add other filetypes and their corresponding run commands here
	},
	buffer_height = 10, -- height in lines
	focus_back = false, -- whether to set focus back to the original window
}

-- load the core module
local core = require("coderunner.core")

-- create a setup function for user to initialize
function M.setup(config)
	M.config = vim.tbl_deep_extend("force", M.config, config or {})

	-- setup the core functionality
	core.setup(M.config)
end

return M
