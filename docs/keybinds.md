# Keybinds pane

A cheat sheet per application. The `keybinds` menu lists them (Neovim,
Tmux, and whatever a config adds), and picking one opens a pane with that
app's binds drawn as keycaps, in groups, over two columns. Omarchy quattro
shows its keybindings as a searchable list in its menu; this keeps the
search but gives each app its own page, which reads better when the binds
are many and grouped.

```
qs -p $SARISARINAMA_PATH ipc call shell toggle menu '{"file": "~/.config/sarisarinama/keybinds.json"}'
qs -p $SARISARINAMA_PATH ipc call shell summon keybinds '{"section": "tmux"}'
```

The first opens the menu, the second the pane straight on a section. A
payload without `section` shows the one shown last. The root menu has a
`Keybinds` row. The shell binds no key itself: canaima binds `mod` + `?`
(`mod` + `Shift` + `/`) to the menu. Not `mod` + `k`, which is Sway's
focus up.

## Where the binds come from

`programs.sarisarinama.keybinds.<id>`, one section each, rendered to
`~/.config/sarisarinama/cheatsheets.json` in menu order. The menu is built
from the same sections, so a new section is a new row with nothing else to
write. It is not `keybinds.json`: that name is the menu's.

```nix
programs.sarisarinama.keybinds.lazygit = {
  label = "Lazygit";
  order = 40;
  groups = [
    {
      title = "Files";
      binds = [
        { keys = "Space"; description = "Stage the file"; }
        { keys = "c"; description = "Commit"; }
      ];
    }
  ];
};
```

`keys` is the notation the pane draws: `+` joins the keys of one chord, a
space separates chords pressed in turn. `Ctrl+b c` is two chords, `Space f f`
three. A key written `{motion}` is drawn in italics, not on a keycap: it is
something to type. The key `+` is written `Plus`, the space bar `Space`.

`groups` is a list, and list definitions concatenate: a config adds a group
to a preset with `lib.mkAfter [ ... ]` and replaces the preset's groups
with `lib.mkForce [ ... ]`. `order` sorts the sections (lower first, ties
by name); a section with no binds is left out of the file and the menu.

Two presets ship (`modules/ui/keybinds/presets/`):

- `neovim` (order 10): the base flavor of
  [kukenan](https://github.com/juanalbarran/kukenan), from its
  `docs/keybinds.md`. Leader is Space.
- `tmux` (order 20): tmux's defaults, Ctrl+b prefix and vi copy mode,
  checked against `tmux list-keys`.

The compositor's section is the config's to build, from its own binds.
canaima's `modules/ui/keybinds.nix` builds a `sway` section (order 30) from
`ui.apps`, `ui.binds` and Sway's final keybinding table.

## Keys

Typing filters: case-insensitive, on what a bind does and on its keys; a
group whose title matches keeps all its binds. The matches are picked out
in the accent colour, keycaps included. The filter stays when the section
changes, so one word can be looked up across apps.

| Key                          | Does                                     |
| ---------------------------- | ---------------------------------------- |
| `Tab` / `Shift+Tab`          | Next / previous section                  |
| `Ctrl+N` / `Ctrl+P`, `↓`/`↑` | Scroll                                   |
| `Ctrl+D` / `Ctrl+U`, PgDn/Up | Scroll half the pane                     |
| `Esc`                        | Clear the filter; on an empty one, close |

There is nothing to select, so unlike the panels there is no cursor and
`Ctrl+N`/`Ctrl+P` scroll. A click on a section's pill shows it too.

## Files (`quickshell/panes/keybinds/`)

| File                | Role                                                     |
| ------------------- | -------------------------------------------------------- |
| `KeybindsPanel.qml` | PanelWindow; host contract, keys, the scrolling body     |
| `KeybindsState.qml` | Reads `cheatsheets.json`; section in view, filter        |
| `keymodel.js`       | Keys to keycaps, the filter, columns, highlighting; pure |
| `Header.qml`        | Icon, name, bind count, one pill per section             |
| `Filter.qml`        | The filter box; hands the pane's keys to the panel first |
| `Columns.qml`       | The groups over the columns, down then across            |
| `GroupBlock.qml`    | A group's heading and rows                               |
| `BindRow.qml`       | Keys on the left, description on the right               |
| `KeyCombo.qml`      | A bind's chords, as keycaps joined by `+`                |
| `Keycap.qml`        | One key                                                  |
| `Hints.qml`         | The pane's own keys, along the bottom                    |

And `modules/ui/keybinds/`: `options.nix` (the option), `render.nix`
(`cheatsheets.json` and the `keybinds` menu), `presets/`.

## Looks

`style.keybinds` is every panel's keys from `_lib/panel.nix`, with a card
820 px wide, plus:

| Key                               | Default | Meaning                               |
| --------------------------------- | ------- | ------------------------------------- |
| `columns.count`                   | 2       | Columns the groups spread over        |
| `columns.gap`, `columns.groupGap` | 28, 18  | Between columns, between groups       |
| `columns.keysWidth`               | 0.38    | Share of a column the keys take       |
| `keycap.paddingX`, `.paddingY`    | 6, 2    | Inside a keycap                       |
| `keycap.radius`, `.depth`         | 4, 2    | Corners, lower edge; not scaled       |
| `keycap.gap`, `.stepGap`          | 4, 10   | Within a chord, between chords        |
| `maxHeight`                       | 0.75    | Share of the screen before it scrolls |

`theme.surfaces.keybinds` is every panel's tokens plus `keycap`
(`lighter_background`), `keycapEdge` (`muted`), `keycapText` (`foreground`)
and `match` (`accent`: group headings and filter matches).

## Status

Checked in a headless Sway with canaima's real data: all three sections,
filtering, `Tab`/`Shift+Tab`, scrolling, `Esc` twice, and the menu row
opening the pane. canaima's `mod` + `Shift` + `/` fires in Sway. Not yet
used on a real screen.

- The tmux preset is tmux's defaults; a config that rebinds tmux must add
  its own group (canaima does, by hand, so it can drift from its tmux
  config).
- Neovim's binds are copied from kukenan's docs, not read from Neovim.
- Hyprland has no section: canaima builds one from Sway's table only.
