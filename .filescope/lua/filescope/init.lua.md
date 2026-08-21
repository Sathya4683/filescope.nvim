# init.lua

## Purpose

Main FileScope module.

This file contains the core plugin logic and public API.

## Responsibilities

- Detect the current buffer's file.
- Find the Git repository root.
- Map a source file to its `.filescope` note.
- Open and close the attached note window.
- Mark FileScope note buffers.
- Expose the `setup()` function.

## Core flow

## Adding more notes!!!

```text
current buffer
    ↓
get_current_file()
    ↓
get_repo_root()
    ↓
get_note_path()
    ↓
M.toggle()
    ↓
vsplit note
