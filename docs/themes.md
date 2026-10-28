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
`hover`, `urgent`, `warning` and `charging`.

Omarchy bakes the hex in at theme-set time, because it re-renders on every
switch; the reference is kept instead, so switching swaps one small file and
every surface follows. Three departures: no `[hyprland]` block, since the
shell also runs under Sway and borders point at `accent`; one block per
component that exists, `bar` and `menu`, so omarchy's `popups`, `tooltip`,
`notifications`, `launcher`, `polkit` and `image-picker` are absent
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
qs -p $SARISARINAMA_PATH ipc call theme entries catppuccin
qs -p $SARISARINAMA_PATH ipc call theme get
qs -p $SARISARINAMA_PATH ipc call theme set vantablack
```

`set` validates against `theme.json`'s `available`, so a name it accepts is
one Nix rendered. It assigns `Colors.selected` first and writes the file
after: the write is asynchronous, so re-reading it would race, and the UI
must switch now. The file is only how the choice survives a restart.

`entries` is the Themes menu, a JSON array of rows (#52). A theme's family
is its name up to the first dash, and a family of two or more is one row
that opens a level of its own: `catppuccin` holds `latte` and `mocha`,
`gruvbox` holds `dark` and `light`. A flavor is labelled by the rest of its
name, and the one named as the family, which has no rest, by its mode, from
`theme.json`'s `modes`. A theme alone in its family, such as
`kanagawa-dragon`, stays a row of its own, so a second flavor added later
groups both without any other change. The menu file is one command,
`ipc call theme entries {arg}`, that reopens itself with the family as
`{arg}`, `""` at the top, as the project menu does with a directory.

## Wallpapers

Each theme has a directory of images at the root of the repository,
picked up by name: dropping an image there is enough. A theme alone in its
family has `wallpapers/<theme>/`; a family of flavors has one directory
with a subdirectory per flavor, named as the themes menu labels it (#56):

| Directory                    | Theme                                 |
| ---------------------------- | ------------------------------------- |
| `white/`                     | `white`                               |
| `catppuccin/latte/`          | `catppuccin-latte`                    |
| `catppuccin/mocha/`          | `catppuccin-mocha`                    |
| `gruvbox/dark/`, `light/`    | `gruvbox` (its mode), `gruvbox-light` |
| `everforest/dark/`, `light/` | `everforest`, `everforest-light`      |
| `rose-pine/dark/`, `dawn/`   | `rose-pine`, `rose-pine-dawn`         |

A subdirectory is `<family>-<flavor>` when that theme exists, else the
family's own theme when the flavor is its mode. When a theme is selected
its default is shown on every screen, below every window;
`theme.wallpapers.<theme>.default` names it, and null means the first by
name, as in omarchy. A config may point a theme at a directory of its own
with `theme.wallpapers.<theme>.directory`. A theme with no wallpaper, no
directory or one with no image in it, shows its `background` colour; the
empty flavors keep a `.gitkeep` so the directory is there to drop into.

The images come from omarchy, each theme's first background:

| Theme              | Image                                                  |
| ------------------ | ------------------------------------------------------ |
| `tokyo-night`      | `tokyo-night/0-liftoff.webp`, omarchy's out of the box |
| `vantablack`       | `vantablack/0-dot-hands.webp`                          |
| `white`            | `white/1-white.webp`                                   |
| `catppuccin-latte` | `catppuccin-latte/1-color-fade.webp`                   |
| `catppuccin-mocha` | `catppuccin/1-totoro.webp`                             |
| `gruvbox`          | `gruvbox/1-the-backwater.jpg`                          |
| `gruvbox-light`    | none; omarchy has no light gruvbox                     |
| `everforest`       | `everforest/1-tree-tops.webp`                          |
| `everforest-light` | none; omarchy has no light everforest                  |
| `rose-pine-dawn`   | `rose-pine/1-funky-shapes.webp`                        |
| `rose-pine`        | none; omarchy has no dark rose-pine                    |
| `kanagawa-dragon`  | `kanagawa/1-kanagawa.jpg`                              |
| `no-clown-fiesta`  | `matte-black/0-ship-at-sea.jpg`; omarchy has no ncf    |

Qt as packaged in nixpkgs decodes jpg and png but not webp, which most of
omarchy's are, so every other format is converted to JPEG at build time.
`wallpapers.json` holds, per theme, the default and every image, as store
paths, plus `rotate`; like `theme.json`, the shell never scans a directory. The shell
draws them itself, a layer-shell window on the background layer per
screen, so it works under Sway and Hyprland alike, with no swaybg.

### Switching wallpapers

Within the current theme, as omarchy's `theme bg next` and its background
switcher:

```
qs -p $SARISARINAMA_PATH ipc call wallpaper next      # and previous; both wrap
qs -p $SARISARINAMA_PATH ipc call wallpaper list
qs -p $SARISARINAMA_PATH ipc call wallpaper set 1-winding-road.jpg
```

The Wallpaper menu (`wallpaper.json`, no root row) opens the same list, each row
with its image as the icon. A file is named as `list` prints it: after
conversion, so a `.webp` is set as `.jpg`.

The image picked for each theme is remembered, by file name, in
`$XDG_STATE_HOME/sarisarinama/wallpapers.json`, the shell's own state like
`current.json`. Selecting a theme shows its pick, or its default when it
has none or the file is gone from its directory. `theme.rotateWallpapers`
moves to the next image every so many minutes, `0` (the default) never:
omarchy has no rotation. A rotation step is remembered like a pick.

The lock screen shows the same image, blurred and dimmed, see
[lock](./lock.md#looks).

## Applications

The theme reaches past the shell through integrations: each is a script
the shell runs after a `theme set`, with the theme's name, by listing
itself in `theme.onSet`, and Home Manager runs on every switch, so a
changed palette lands without a `set`. Each is
`programs.sarisarinama.integrations.<name>.enable`, as omarchy's
`bin/omarchy-theme-set-*` are each one program.

| Integration   | Follows the theme                     | On by default                      |
| ------------- | ------------------------------------- | ---------------------------------- |
| `foot`        | colours, open windows included        | with `programs.foot.enable`        |
| `tmux`        | panes, bar, borders, `COLORFGBG`      | with `programs.tmux.enable`        |
| `palette`     | `palette.json`, what Neovim reads     | yes                                |
| `mode`        | dark or light, for GTK and the portal | yes                                |
| `qutebrowser` | dark pages, the setting `,d` cycles   | with `programs.qutebrowser.enable` |

### foot and tmux

Both read their config only at start, so both have the same two halves:
every palette is rendered as a file of their own, `foot/<name>.ini` and
`tmux/<name>.conf`, and their config includes one copy of it in
`$XDG_STATE_HOME/sarisarinama/`, which a switch replaces. That covers what
starts later; what is running is repainted too. foot gets the colours as
OSC sequences; tmux sources the copy into its server, so every session
changes at once. The sixteen colours are mapped once, in
`integrations/_lib/ansi.nix`, so foot's colour 4 is tmux's.

tmux paints its panes itself, with `window-style` and `pane-colours`, so
they follow the theme in any terminal. The bar and borders take
omarchy's `config/tmux/tmux.conf`: its `brightblack` is `muted` and its
`blue` is `accent`. A theme can repoint either with
`integrations.tmux.roles.<theme>.subtle` (other windows' names, pane
borders) or `.highlight` (the current window, the active border,
messages), a palette key or a literal `#rrggbb`. `no-clown-fiesta` sets
`subtle` to `dark_foreground`: its `muted`, `#373737`, is too dark to read on
`#0d0d0d`. The copy is sourced last in tmux's config, so its
styles win over earlier ones. `COLORFGBG`, `15;0` dark and `0;15` light,
is how a program in a new pane tells which it is in.

### Neovim

kukenan reads `palette.json`, which the `palette` integration rewrites on
every switch, and paints itself through aether.nvim, as omarchy's
`default/themed/neovim.lua.tpl` does. It watches the file, so an open
Neovim changes too, and sets `background` from `mode`.

A theme that is itself a Neovim colorscheme is painted by that one instead,
keyed on the palette's `name`: aether maps the 26 keys onto groups of its
own, so it never looks like the original. Today that is `no-clown-fiesta`:
kukenan loads no-clown-fiesta.nvim with only its `bg` set to the palette's
`background` (#46).

### Dark and light

A palette's `mode` is written to dconf, as omarchy's
`omarchy-theme-set-gnome`: `color-scheme` is `prefer-dark` or
`prefer-light`, and `gtk-theme` is `Adwaita-dark` or `Adwaita`. GTK reads
the second; the settings portal hands the first to whatever asks —
Firefox, Chromium, GTK 4 and libadwaita apps — which switch while open.
dconf needs the session bus; with none, as from a TTY, the script does
nothing and the next `set` or switch catches up.

### qutebrowser

Dark pages follow `mode`: `colors.webpage.darkmode.enabled`, the setting
the `,d` key cycles, is on with a dark theme and off with a light one. Like
Neovim, qutebrowser reads `palette.json` itself, so there is no script: a
few lines appended to its `config.py` read it at start and watch its
directory, and an open qutebrowser changes at once (QtWebEngine 6.7 or
newer; older ones need a restart). The setting changes only when the
mode does, so a page toggled with `,d` stays as it is until the next
switch between dark and light; a wallpaper rotation writing beside
`palette.json` leaves it alone.

The other way, sending `:set` to the running qutebrowser, is how commands
reach it from outside, and it raises the window: under Sway the window is
marked urgent on every switch. Tested on a headless Sway.

## Files

| File                                        | Role                                |
| ------------------------------------------- | ----------------------------------- |
| `modules/ui/theme/_lib/mix.nix`             | Hex arithmetic: `mix`, `isLight`    |
| `modules/ui/theme/_lib/palette.nix`         | The cascade                         |
| `modules/ui/theme/options.nix`              | `theme.default`, `theme.palettes`   |
| `modules/ui/theme/presets/*.nix`            | One palette each                    |
| `modules/ui/theme/surfaces.nix`             | `theme.surfaces.*`, the token map   |
| `modules/ui/theme/render.nix`               | Writes all three kinds of file      |
| `quickshell/theme/Colors.qml`               | Reads all three, resolves a key     |
| `quickshell/theme/BarColors.qml`            | The `bar` block, with its defaults  |
| `quickshell/theme/MenuColors.qml`           | The `menu` block, with its defaults |
| `quickshell/theme/ThemeIpc.qml`             | `theme get`/`list`/`set` over IPC   |
| `wallpapers/<theme>/`, `<family>/<flavor>/` | The images, one directory per theme |
| `modules/ui/theme/wallpapers/options.nix`   | `theme.wallpapers`, found by name   |
| `modules/ui/theme/wallpapers/render.nix`    | Converts, writes `wallpapers.json`  |
| `quickshell/wallpaper/Wallpaper.qml`        | The current image, every screen     |
| `quickshell/wallpaper/WallpaperIpc.qml`     | `wallpaper next`/`set`/`entries`    |
| `quickshell/theme/Wallpapers.qml`           | Current image, picks, rotation      |
| `modules/ui/menu/presets/wallpaper.nix`     | The Wallpaper menu                  |
| `integrations/_lib/current-theme.sh`        | Which theme a script applies        |
| `integrations/_lib/ansi.nix`                | The sixteen colours, by palette key |
| `integrations/foot/`                        | foot: files, script, activation     |
| `integrations/tmux/`                        | tmux: files, script, activation     |
| `integrations/palette/`                     | `palette.json`, for Neovim          |
| `integrations/mode/`                        | Dark or light, in dconf             |
| `integrations/qutebrowser/`                 | Dark pages, from `palette.json`     |

`integrations/` is `modules/ui/theme/integrations/`.

import-tree skips any path holding `_`, so `_lib/` holds plain functions.

## Status

Done. The cascade was checked against `bin/omarchy-theme-color` on all 22
omarchy themes: 572 of 572 keys identical. Surfaces, `Colors.qml` and
switching over IPC are in and verified: a `set` repoints `paletteFile`,
every bound surface follows, and the choice survives a restart.

Thirteen presets: `no-clown-fiesta` (the default: every key an upstream colour
from no-clown-fiesta.nvim's `dark` palette, mapped as its highlights use
it, but the background darkened to `#0d0d0d` and the six bright hues
derived, since upstream has none; #46), `tokyo-night` (omarchy's own default), `vantablack`
and `white` (both 21:1, the highest contrast omarchy ships) and `kanagawa-dragon`
(not an omarchy theme; mapped from kanagawa.nvim's dragon `term` table the same
way omarchy maps wave), `catppuccin-latte` (omarchy's, verbatim: #42 had
it on white's `#ffffff`, which #48 took back to Latte's `#eff1f5`) and
`catppuccin-mocha` (omarchy's `catppuccin`, verbatim, with its three
backgrounds; #50), `gruvbox` (omarchy's, verbatim, with its five
backgrounds) and `gruvbox-light` (not an omarchy theme: omarchy's gruvbox
mirrored, gruvbox's light ramp where it has the dark one and
gruvbox-material's light hues where it has the dark ones; #51),
`everforest` (omarchy's, verbatim, with its one background) and
`everforest-light` (not an omarchy theme: omarchy's everforest mirrored onto
everforest's light ramp and hues, with `muted` and `dark_foreground` picked
by contrast where the flatter light ramp would hide them; #54),
`rose-pine-dawn` (omarchy's `rose-pine`, with rose-pine/neovim's current
text and subtle in place of its older two, and its three backgrounds) and
`rose-pine` (not an omarchy theme: rose-pine/neovim's main, keyed as
omarchy keys Dawn, and no moon; #55). Eight of those thirteen are omarchy's, so 14 of
its 22 are still to port.

Two rough edges: the shell paints its QML defaults for a tick at startup
before the palette loads, and `ConfigFile` warns about `current.json` on
every start although that file is meant to be absent until the first `set`.

Applications: foot, tmux, Neovim, qutebrowser and dark or light follow a
`set`. The tmux and dark-or-light scripts are tested on a private tmux
server and a private session bus, qutebrowser on a headless Sway with
canaima's own `config.py`, and canaima builds with all of them; not yet
seen on screen.
GTK 3 is left at `gtk-theme`, unchecked live: the GTK 3 apps installed
(Lutris, Blueman, nm-connection-editor, GParted) are rarely open. Chrome and
Slack are not GTK 3; they follow `color-scheme`. qutebrowser has its own
integration; other Qt apps have none.
