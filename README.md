# coderunner

coderunner is a lightweight plugin for NeoVim which enables you to run code in various languages directly from your NeoVim editor. The plugin supports a variety of file types and provides a split terminal window to display the output of your code.

## Install

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    "neysanfoo/coderunner.nvim",
    config = function()
        require("coderunner").setup({
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
            focus_back = false, -- whether to set the cursor back to the original window after running the code
        })
        -- Optional: Add a keybinding
        vim.keymap.set("n", "<Leader>i", "<cmd>Run<cr>", { noremap = true, silent = true })
    end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use 'neysanfoo/coderunner.nvim'
```

## Setup

The plugin can be configured in lua. Here is a minimal config.

```lua
require('coderunner').setup {
  filetype_commands = {
    python = 'python3 -u "$fullFilePath"',
    lua = "lua",
    c = { 'gcc "$fullFilePath" -o "$dir/out"', '"$dir/./out"' },
    cpp = { 'g++ "$fullFilePath" -o "$dir/out"', '"$dir/./out"' },
    java = { 'javac "$fullFilePath"', 'java -cp ".:$dir" "$fileNameWithoutExt"' },
    javascript = 'node "$fullFilePath"',
    -- add other filetypes and their corresponding run commands here
  },
  buffer_height = 10,  -- height in lines
  focus_back = false   -- whether to set the cursor back to the original window after running the code
}
```

To create your own `filetype_commands`, simply add a key-value pair to the
`filetype_commands` table in your setup configuration. The key should be the
filetype (like `python`, `c`, `cpp`, etc.) and the value should be the command
you want to run for that filetype. The command can use the placeholders `$dir`,
`$fullFilePath`, and `$fileNameWithoutExt` which will be replaced with the directory
of the file, the full file path, and the file name without extension respectively.

### Note on Paths with Spaces

When configuring commands, wrap the path placeholders in quotes to handle paths containing spaces:

```lua
-- Good: Handles paths with spaces
python = 'python3 -u "$fullFilePath"'

-- Not recommended: May fail with spaces in path
python = "python3 -u $fullFilePath"
```

## Commands

- `:Run`: Runs the current file. It pulls the associated command from your `filetype_commands` configuration.
  The command is run in a new split window at the bottom, allowing you to view your code's output within NeoVim.
  If focus_back is set to true, the cursor automatically returns to your original file. The output split can be
  closed by typing either `:q` or `q` in normal mode, or any key in insert mode after the process has exited.

### Example Configurations

Simple interpreted languages:

```lua
filetype_commands = {
    python = 'python3 -u "$fullFilePath"',
    javascript = 'node "$fullFilePath"',
}
```

Compiled languages:

```lua
filetype_commands = {
    cpp = { 'g++ "$fullFilePath" -o "$dir/out"', '"$dir/./out"' },
    rust = { 'rustc "$fullFilePath" -o "$dir/out"', '"$dir/./out"' },
}
```

Languages with special requirements:

```lua
filetype_commands = {
    java = { 'javac "$fullFilePath"', 'java -cp ".:$dir" "$fileNameWithoutExt"' },
}
```
