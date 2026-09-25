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

A file is an array of entries, or an object that produces them. An entry
has `icon`, `label` and exactly one of:

- `action`: a command, run with `bash -lc`; the menu closes afterwards.
- `menu`: the path of another menu file; opened as a submenu.

A submenu shows a synthetic **Back** row; `h`/Backspace also go back.
Keys: `Ctrl+N`/`Ctrl+P`/arrows move, `l`/Enter activate, Escape closes.

### Command menu

Instead of an array, a file may be one object. Its `command` runs when the
menu opens and every non-empty line of stdout becomes a row:

```json
{
  "command": "qs -p {shell} ipc call theme list",
  "icon": "󰏘",
  "action": "qs -p {shell} ipc call theme set {}"
}
```

`{}` is replaced by the line and `{shell}` by the running config path, so a
row can reach the shell over IPC wherever it was launched from. The command
re-runs on every open, so the list is never stale. Nothing checks its exit
code: a command that prints an error to stdout makes a row of that error.

### Files (`quickshell/menu/`)

| File          | Role                                                                |
| ------------- | ------------------------------------------------------------------- |
| `Menu.qml`    | PanelWindow; host contract `open(payloadJson)`, `close()`, `opened` |
| `Card.qml`    | Background, title (file name), holds the list                       |
| `List.qml`    | ListView, keyboard handling, `activated`/`closeRequested` signals   |
| `Entry.qml`   | One row; talks to its list through `ListView.view`                  |
| `Model.qml`   | Navigation stack, Back row, `activate(index)`                       |
| `File.qml`    | FileView wrapper: path expansion, JSON parsing, error handling      |
| `Command.qml` | Runs a command menu's `command`, turns its lines into entries       |

Data flows down (window, card, list, row); events flow up as signals.
Nothing below `Menu.qml` knows about the window.

Naming note: a local file loses to a type of the same name from an imported
module (`Row.qml` vs QtQuick `Row`). Pick names no module exports.

### Looks

Geometry and type are the `menu` section of `style.json`, colors the `menu`
block of `surfaces.json`. The menu may override the shared font and scale:
`style.menu.font.size` raises the rows without touching the bar, and the row
height follows it. See [style](./style.md) and [themes](./themes.md).

## Project menu (planned)

Opens a directory. If it contains only subdirectories, list them; selecting
one opens another project menu. If it contains files, it is a project: open a
`herdr` instance running the `nvim-base` app, honoring `herdr.toml` in the
project directory when present.

- `herdr` is my multiplexer (not written yet).
- `nvim-base` is the `base` flavor of my neovim config
  [kukenan](https://github.com/juanalbarran/kukenan).

Open questions: mixed files and directories, hidden files, empty directories.
A command menu covers part of this already: `ls` plus an `action` template.
