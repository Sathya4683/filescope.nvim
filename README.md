<div align="center">

# filescope.nvim

**Contextual notes for every file, kept right next to your code and tracked by git.**

![Neovim 0.10+](https://img.shields.io/badge/Neovim-0.10%2B-blue)
![Lua](https://img.shields.io/badge/Language-Lua-blue)
![License MIT](https://img.shields.io/badge/License-MIT-lightgrey)

</div>

---

## Why

You're deep in `auth/session.lua`, you figure out something tricky, and you want to leave a note for future you or a teammate. Comments clutter the file. Notion or Obsidian disconnects the note from the code. Commit messages get buried in `git log` two weeks later.

filescope gives every file its own markdown note, stored in a folder that mirrors your project structure. Toggle it open next to the file, write context, and close it. The note lives in your repo. Commit `.filescope/` to share context with your team, or gitignore it to keep it for yourself.

## Features

- Open notes in any direction: left, right, top, or bottom
- Notes mirror your file tree under `.filescope/`, so they are easy to grep, browse, or commit
- Auto-wipes the note buffer on close by default, or keep it loaded if you prefer
- Zero dependencies, pure Lua
- One file, no bloat

## Demo

(Add a GIF here. A short recording of the four-direction toggle in action is worth more than any amount of written description.)

## Requirements

- Neovim 0.10 or newer (uses `vim.fs.root` and `vim.fs.relpath`)
- Works outside git too, falls back to your cwd if there is no `.git`

## Installation

<details open>
<summary>lazy.nvim</summary>

```lua
{
  "Sathya4683/filescope.nvim",
  keys = {
    { "<leader>fs", function() require("filescope").toggle() end, desc = "FileScope: toggle" },
    { "<leader>fh", function() require("filescope").toggle({ direction = "left" }) end, desc = "FileScope: toggle left" },
    { "<leader>fl", function() require("filescope").toggle({ direction = "right" }) end, desc = "FileScope: toggle right" },
    { "<leader>fk", function() require("filescope").toggle({ direction = "top" }) end, desc = "FileScope: toggle top" },
    { "<leader>fj", function() require("filescope").toggle({ direction = "bottom" }) end, desc = "FileScope: toggle bottom" },
  },
  config = function()
    require("filescope").setup({
      direction = "right",
      size = 0.5,
      close_buffer = true,
    })
  end,
}
```

</details>

## Configuration

`setup()` accepts:

| Option         | Type      | Default   | Description                                                                                 |
| -------------- | --------- | --------- | --------------------------------------------------------------------------------------------- |
| `direction`    | `string`  | `"right"` | Where the note opens: `"left"`, `"right"`, `"top"`, `"bottom"` (aliases `"up"` and `"down"`) |
| `size`         | `number`  | `0.5`     | Fraction of the screen the note window takes                                                |
| `close_buffer` | `boolean` | `true`    | Wipe the note buffer when toggled closed. `false` keeps it loaded and hidden instead        |

Any of these can also be overridden per call, so different keybinds can behave differently:

```lua
-- this one keeps its buffer alive even after closing
require("filescope").toggle({ close_buffer = false })
```

## Usage

- `<leader>fs` toggles the note for the current file
- `:FileScope` does the same, as a command
- `:FileScope left|right|top|bottom` toggles open in a specific direction

Notes live at `<git-root>/.filescope/<relative-path-to-file>.md`. Toggling again closes the window, and by default wipes the buffer as long as there is nothing unsaved in it.

## FAQ

**Should I commit `.filescope/`?**
Your call. Commit it if the notes double as living documentation for your team. Gitignore it if it's just your own scratch space.

**What happens if the note has unsaved changes when I close it?**
It's kept loaded and you get a warning. filescope never silently discards unsaved notes.

**No git repo?**
Notes fall back to `<cwd>/.filescope/...`.

## Contributing

Issues and PRs welcome. Keep it small, this plugin is intentionally minimal.

## License

MIT
