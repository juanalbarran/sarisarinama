# Menu

Inspired by the omarchy menu; the code to read is
`vendor/omanix-shell/plugins/menu/` in omanix. Two kinds, both done.

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

A submenu shows a synthetic **Back** row, the only way back. Keys:
`Ctrl+N`/`Ctrl+P` move, Enter activates, Escape closes; nothing else.

### Long menus

A menu shows at most `list.maxRows` rows (8) and scrolls to keep the
current one in view. One with more entries than `list.filterAbove` (5) gets
a filter box above the list. The box holds the keyboard: what is typed keeps
the entries whose label contains it, ignoring case, and the first match is
selected. Back is not an entry: it is never counted and never filtered out.
A new menu starts with an empty filter.

### Root and services menus

`root.json` (`presets/main.nix`) is kept short: Applications, Themes,
Services and System, in that order. The panels sit one level
down, in `services.json` (`presets/services.nix`): Network, Bluetooth,
VPN, Monitors and Sound, each summoning its panel as a click on its bar
icon does. Projects, Bookmarks, Wallpaper and Keybinds keep their menus but have
no root row; a config opens them with keybinds of its own, as canaima does
for Services, Themes and System:

```
qs -p $SARISARINAMA_PATH ipc call shell toggle menu '{"file":"~/.config/sarisarinama/services.json"}'
```

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
row can reach the shell over IPC wherever it was launched from. `{arg}` is
replaced by the `arg` the opening row (or the IPC payload) carried, quoted
as one shell word, so one file can serve many directories. The command
re-runs on every open, so the list is never stale. Nothing checks its exit
code: a command that prints an error to stdout makes a row of that error.

Stdout that parses as a JSON array is taken as the entries themselves, so
one command can mix rows that act with rows that open a submenu; a row may
carry an `arg` for the menu it opens. `"backWithin": true` limits Back to
this same file: where the menu was first opened there is no Back row.

### Applications menu

The root menu's first row. It lists what `wofi --show drun` lists: every
`.desktop` file on `XDG_DATA_DIRS` that is not `NoDisplay`, sorted by name.
The file names a source instead of a command:

```json
{ "source": "applications" }
```

The shell builds the rows itself from Quickshell's `DesktopEntries`; no
command runs, so `{}`, `{arg}` and `{shell}` mean nothing here.
`DesktopEntries` scans in the background and adds one app at a time, so the
list fills in while the menu is open. It is longer than `list.filterAbove`,
so typing filters it, as wofi's search box does. A row shows the app's icon
from the icon theme, or the `󰀻` glyph when the theme has none. Enter
launches the app through the entry's own `execute()`, and the menu closes.

In Nix it is `menus.applications = { source = "applications"; }`, in
`modules/ui/menu/presets/applications.nix`. A command menu takes exactly one
of `command` or `source`, and `render.nix` asserts it.

Not yet checked on screen. Two things are open: whether `execute()` opens
a terminal for an app marked `Terminal=true`, and whether the icons are
found under NixOS, which depends on Qt knowing the icon theme.

### Bookmarks menu

Not in the root menu: a config opens `bookmarks.json` with a keybind. Two levels, as canaima's wofi
`bookmarks` script had: a row per category, then a row per link. Both are
plain list menus, rendered by `render.nix` like any other, so the shell
knows nothing about bookmarks.

They are declared in Nix, in the config that uses the module, not in this
repo:

```nix
programs.sarisarinama.bookmarks = {
  browser = "qutebrowser";
  categories = {
    code.links = [
      {label = "Github"; url = "https://github.com/juanalbarran";}
    ];
    work = {
      label = "Work";
      browser = "brave";
      links = [{label = "ctwo"; url = "https://ctwo.com";}];
    };
  };
};
```

Each category becomes `bookmarks-<name>.json`, and `bookmarks.json` lists
them, in attribute order, which Nix sorts by name. A category's `label` is
its name unless set. A link row runs the category's `browser`, or
`bookmarks.browser` (`xdg-open` by default), with the URL quoted as one
shell word; the menu closes. A browser already open gets the URL in its
own window, so nothing focuses it first. A category with more than
`list.filterAbove` links gets the filter box.

`bookmarks.json` is written even with no categories, as an empty menu, so
the root row never points at a missing file. Adding a bookmark means a
rebuild; there is no runtime file to edit.

The options and both menus are `modules/ui/menu/presets/bookmarks.nix`.
Not yet checked on screen.

### Files (`quickshell/menu/`)

| File               | Role                                                                |
| ------------------ | ------------------------------------------------------------------- |
| `Menu.qml`         | PanelWindow; host contract `open(payloadJson)`, `close()`, `opened` |
| `Card.qml`         | Background, title (file name), filter box, the list                 |
| `Search.qml`       | The filter box; hands the four menu keys to the list                |
| `List.qml`         | ListView, the four keys, scrolling, `activated`/`closeRequested`    |
| `Entry.qml`        | One row, icon image or glyph; talks to its list via `ListView.view` |
| `Model.qml`        | Navigation stack, filter, Back row, `activate(index)`               |
| `File.qml`         | FileView wrapper: path expansion, JSON parsing, error handling      |
| `Command.qml`      | Runs a command menu's `command`, turns its lines into entries       |
| `Applications.qml` | The `applications` source: desktop entries as rows, sorted          |

Data flows down (window, card, list, row); events flow up as signals.
Nothing below `Menu.qml` knows about the window.

Naming note: a local file loses to a type of the same name from an imported
module (`Row.qml` vs QtQuick `Row`). Pick names no module exports.

### Looks

Geometry and type are the `menu` section of `style.json`, colors the `menu`
block of `surfaces.json`. The menu may override the shared font and scale:
`style.menu.font.size` raises the rows without touching the bar, and the row
height follows it. `style.menu.list` holds the two counts above, read raw
and never scaled. The filter's hint is `menu.placeholder` in
`surfaces.json`, `muted` by default. See [style](./style.md) and
[themes](./themes.md).

## Project menu (done)

`sarisarinama-projects-menu [dir]` is the entry point, and what a config binds
to a key (canaima: `mod` + `p`). No `dir` means `projects.root`. A project
opens straight in tmux; anything else opens the menu at that directory,
over IPC (`summon`, so an open menu moves there instead of closing):

```
sarisarinama-projects-menu ~/dev
```

A directory is a **project** when it holds any of `.git`, `devenv.nix`,
`.gitignore`, `.tmux-init.conf` or `agents.md`. The rule lives once, in
`_lib/is-project.sh`. Anything else is a **branch**: the menu lists its
subdirectories, hidden ones skipped, and a branch row opens the same menu
one level down. Back appears only below the directory it was opened at.

### Opening a project

A tmux session named after the directory (`.` and `:` become `_`), every
window started in it, in this order:

| Window     | Runs        | With `devenv.nix`        |
| ---------- | ----------- | ------------------------ |
| `agent`    | `claude`    | `devenv shell claude`    |
| `editor`   | `nvim-base` | `devenv shell nvim-base` |
| `terminal` | a shell     | `devenv shell`           |

Each app is typed into its window's shell, so quitting it leaves a shell.
With devenv the app goes on the same line, so it never starts before the
environment does.

A project with a **`.tmux-init.conf`** gets none of these windows: the file
builds the whole session. It is a bash script, run as canaima's
`projects.sh` ran it, with `SESSION`, `selected_path` and `bash_path` set,
and it must create the session itself:

```bash
tmux new-session -d -s "$SESSION" -n editor -c "$selected_path"
tmux send-keys -t "$SESSION:editor" "devenv shell" C-m
```

Every line runs; a failing one is reported as a notification and the
project still opens. A file that creates no `$SESSION` opens nothing. The
file runs once, when the session is built, and the terminal appears only
after it finishes, so its `sleep`s are waited for.

### Run or raise

One terminal serves every project. A terminal already showing the session
is focused; otherwise the last one used switches to it (`switch-client`);
only with none is a new one opened. The terminal is found by walking up
from the tmux client's pid to a window the compositor knows, so it works
with any terminal and needs no app id. `projects.terminal` picks the one
a new window uses, with the flags it needs before a command (`foot`,
`ghostty -e`).

### Files (`modules/ui/menu/`)

| File                    | Role                                                |
| ----------------------- | --------------------------------------------------- |
| `presets/projects.nix`  | The options, the menu, and the three scripts        |
| `_lib/is-project.sh`    | The project rule, shared by the two scripts below   |
| `_lib/projects-menu.sh` | `sarisarinama-projects-menu`: open or show the menu |
| `_lib/projects.sh`      | `sarisarinama-projects`: one directory as rows      |
| `_lib/open-project.sh`  | `sarisarinama-open-project`: tmux, run or raise     |

Failures in `open-project.sh` show as notifications: it runs detached
from the menu, so stderr goes nowhere.

```

```
