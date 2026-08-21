
### `plugin/filescope.lua.md`

```markdown
# filescope.lua

## Purpose

Neovim plugin entrypoint.

This file is automatically sourced when the plugin is loaded.

## Current behavior

Prevents the plugin from being loaded more than once:

```lua
if vim.g.loaded_filescope then
    return
end

vim.g.loaded_filescope = true
