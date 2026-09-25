# Themes

Colors, and only colors: geometry and type are in [style](./style.md). A
theme is the palette of an omarchy `themes/<name>/colors.toml`; which key
paints which surface is declared once, apart from the themes.

## Palette (`~/.config/sarisarinama/themes/<name>.json`)

One file per theme in `modules/ui/theme/presets/`, holding the keys of the
upstream `colors.toml` verbatim:

```
mode accent selection muted
background dark_background darker_background lighter_background
foreground dark_foreground light_foreground bright_foreground
red yellow orange green cyan blue magenta brown
bright_red bright_yellow bright_green bright_cyan bright_blue bright_magenta
```

26 keys, and every rendered palette has all 26. A theme declares what it
cares about and `_lib/palette.nix` completes it, porting the cascade of
omarchy's `bin/omarchy-theme-color`. Most keys fall back to another key;
only these are computed:

- `dark_background`, `darker_background`: the background 25% and 50% into
  black; `brown`: `orange` 50% into black.
- `bright_red`, `bright_yellow`, `bright_green`, `bright_cyan`,
  `bright_blue`, `bright_magenta`: their base 20% into white. The six hues
  only — `bright_foreground` falls back to `foreground`, it is not mixed.
- `mode`: light when the background's channels sum above 382.

`orange` falls back to `yellow`, `lighter_background` to the background,
and `light_foreground` to the foreground. `color0..color15` are read so a
third-party omarchy theme drops in; only the semantic names are written
back out. `accent` is the one key omarchy leaves to the theme; here it
falls back to `foreground` so the JSON is always well formed.

## Surfaces (`~/.config/sarisarinama/surfaces.json`)

Which key paints what, with the alpha companions, from omarchy's
`default/themed/shell.toml.tpl`. A value names a palette key, or is a
literal `#rrggbb`:

```json
"menu": { "background": "background", "backgroundAlpha": 1.0,
          "text": "foreground", "title": "accent",
          "border": "accent", "borderAlpha": 1.0,
          "selectedBackground": "foreground",
          "selectedBackgroundAlpha": 0.08, "selectedText": "accent" }
```

The `bar` block is `background`, `backgroundAlpha`, `text`, `focused`,
`hover` and `urgent`.

Omarchy bakes the hex in at theme-set time, because it re-renders on every
switch; the reference is kept instead, so switching swaps one small file and
every surface follows. Three departures: no `[hyprland]` block, since the
shell also runs under Sway and borders point at `accent`; one block per
component that exists, `bar` and `menu`, so omarchy's `popups`, `tooltip`,
`notifications`, `launcher`, `polkit`, `lock` and `image-picker` are absent
until those surfaces are; and `menu.title`, which is ours — the card shows
the menu file name and omarchy has no card title.

## Switching

Every theme is rendered, so the choice is not a rebuild. `theme.json` holds
the one Nix picked and the list of every rendered name; `current.json` is
written by the shell and is the only mutable file in the directory. Missing
or unreadable, the shell falls back to `theme.json`, then to the defaults
in QML.

`ThemeIpc.qml` is the only writer, on the `theme` target:

```
qs -p $SARISARINAMA_PATH ipc call theme list
qs -p $SARISARINAMA_PATH ipc call theme get
qs -p $SARISARINAMA_PATH ipc call theme set vantablack
```

`set` validates against `theme.json`'s `available`, so a name it accepts is
one Nix rendered. It assigns `Colors.selected` first and writes the file
after: the write is asynchronous, so re-reading it would race, and the UI
must switch now. The file is only how the choice survives a restart.

## Files

| File                                | Role                                |
| ----------------------------------- | ----------------------------------- |
| `modules/ui/theme/_lib/mix.nix`     | Hex arithmetic: `mix`, `isLight`    |
| `modules/ui/theme/_lib/palette.nix` | The cascade                         |
| `modules/ui/theme/options.nix`      | `theme.default`, `theme.palettes`   |
| `modules/ui/theme/presets/*.nix`    | One palette each                    |
| `modules/ui/theme/surfaces.nix`     | `theme.surfaces.*`, the token map   |
| `modules/ui/theme/render.nix`       | Writes all three kinds of file      |
| `quickshell/theme/Colors.qml`       | Reads all three, resolves a key     |
| `quickshell/theme/BarColors.qml`    | The `bar` block, with its defaults  |
| `quickshell/theme/MenuColors.qml`   | The `menu` block, with its defaults |
| `quickshell/theme/ThemeIpc.qml`     | `theme get`/`list`/`set` over IPC   |

import-tree skips any path holding `_`, so `_lib/` holds plain functions.

## Status

Done. The cascade was checked against `bin/omarchy-theme-color` on all 22
omarchy themes: 572 of 572 keys identical. Surfaces, `Colors.qml` and
switching over IPC are in and verified: a `set` repoints `paletteFile`,
every bound surface follows, and the choice survives a restart.

Five presets: `tokyo-night` (the default), `vantablack` and `white` (both
21:1, the highest contrast omarchy ships), `kanagawa-dragon` (not an
omarchy theme; mapped from kanagawa.nvim's dragon `term` table the same way
omarchy maps wave) and `no-clown-fiesta` (from the neovim theme, background
darkened to `#0d0d0d`). The other 17 omarchy themes are still to port.

Two rough edges: the shell paints its QML defaults for a tick at startup
before the palette loads, and `ConfigFile` warns about `current.json` on
every start although that file is meant to be absent until the first `set`.
