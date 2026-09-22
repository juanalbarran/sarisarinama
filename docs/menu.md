# Menu

Inspired by the omarchy menu; the code to read is
`vendor/omanix-shell/plugins/menu/` in omanix. Two kinds are planned.

## Options menu (done)

A list of entries read from a JSON file in `~/.config/sarisarinama/`. The
file is passed in the summon payload, so one component serves many menus:

```
qs -p $SARISARINAMA_PATH ipc call shell toggle menu '{"file":"~/.config/sarisarinama/root.json"}'
```

No file means `root.json`. A `~` prefix is expanded by the shell.

### JSON contract

A file is an array of entries. Each entry has `icon`, `label` and exactly one of:

- `action`: a command, run with `bash -lc`; the menu closes afterwards.
- `menu`: the path of another menu file; opened as a submenu.

A submenu shows a synthetic **Back** row; `h`/Backspace also go back.
Keys: `j`/`k`/arrows move, `l`/Enter activate, Escape closes.

### Files (`quickshell/menu/`)

| File        | Role                                                                |
| ----------- | ------------------------------------------------------------------- |
| `Menu.qml`  | PanelWindow; host contract `open(payloadJson)`, `close()`, `opened` |
| `Card.qml`  | Background, title (file name), holds the list                       |
| `List.qml`  | ListView, keyboard handling, `activated`/`closeRequested` signals   |
| `Entry.qml` | One row; talks to its list through `ListView.view`                  |
| `Model.qml` | Navigation stack, Back row, `activate(index)`                       |
| `File.qml`  | FileView wrapper: path expansion, JSON parsing, error handling      |

Data flows down (window, card, list, row); events flow up as signals.
Nothing below `Menu.qml` knows about the window.

Naming note: a local file loses to a type of the same name from an imported
module (`Row.qml` vs QtQuick `Row`). Pick names no module exports.

## Project menu (planned)

Opens a directory. If it contains only subdirectories, list them; selecting
one opens another project menu. If it contains files, it is a project: open a
`herdr` instance running the `nvim-base` app, honoring `herdr.toml` in the
project directory when present.

- `herdr` is my multiplexer (not written yet).
- `nvim-base` is the `base` flavor of my neovim config
  [kukenan](https://github.com/juanalbarran/kukenan).

Open questions: mixed files and directories, hidden files, empty directories.
