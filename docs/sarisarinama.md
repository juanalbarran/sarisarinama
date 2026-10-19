# Sarisarinama

The goal here is to create an ui with a `quickshell` instance, for reference check [omanix](https://github.com/T00fy/omanix) or [omarchy](https://github.com/omacom/omarchy/tree/quattro)
This is gonna work as a `flake` that will be inserted into my `NixOS` configuration [canaima](https://github.com/juanalbarran/canaima)
Sarisarinama will be configured as a standalone flake and will use the `dendritic` pattern
The `window manager` `hyprland` or `sway` is meant to auto launch the shell; nothing does that yet, see the status below.

Everything the shell reads is declared in Nix and rendered to
`~/.config/sarisarinama/`: the menus, `style.json`, `surfaces.json`,
`theme.json` and one file per theme. No value is decided in QML — every
font, length and colour comes from those files. The literals left in QML
are fallbacks, one per key, so a missing file still renders something.
`current.json` is the exception: the shell writes it, and Nix does not own
it. How the flake is put together is [nix.md](./nix.md).

## Testing Sarisarinama

The development loop — render the menus, symlink them into
`~/.config/sarisarinama/`, run the shell and toggle a menu over IPC — is in
[development.md](./development.md).

## Components

A component's _content_ is its own module; its _looks_ are shared. Geometry
and type come from `style`, colour from `theme`, so every component looks
like the others without saying so itself.

### Bar

The `bar` component is located at the bottom so it is easier to check the hour, it will contain the `workspaces` at the left and the services icons to the right

For more context [bar](./bar.md)

### Menu

The `menu` will be inspired in the omarchy `menu`, read the code and docs from omarchy quattro. Check [omanix](https://github.com/T00fy/omanix)
There are two kinds of menu: `options menu` and `project menu`
All the menus should contain an option to go back if it is open by another menu

An options menu is a list of entries, or a `command` whose output becomes
the entries when the menu opens. The project menu browses a directory and
opens a project in tmux, one terminal for every project.

For more context [menu](./menu.md)

### Style

Geometry and typography: sizes, padding, the type scale. Shared by every
component, and a component may override the font or the scale for itself —
the menu can run bigger than the bar.

For more context [style](./style.md)

### Theme

Colour, and nothing else. A palette per theme, plus one file saying which
palette key paints which surface, so a theme is swapped at runtime over IPC
without a rebuild:

```
qs -p $SARISARINAMA_PATH ipc call theme set vantablack
```

For more context [themes](./themes.md)

### VPN panel

The NetworkManager VPN profiles, WireGuard and plugin VPNs alike, each
with a switch to bring it up or down. A panel of its own, as omarchy
keeps Tailscale apart from its network panel.

For more context [vpn](./vpn.md)

### Battery panel

The charge, its time left or to full, the battery's health and the power
profile, read from UPower and power-profiles-daemon. After omarchy's power
panel.

For more context [battery](./battery.md)

### Audio panel

Every output and input device, with the volume of the default one and a
row to make another the default, and every app playing sound with its
own volume. Read from PipeWire, after omarchy's audio panel.

For more context [audio](./audio.md)

### Lock screen

The session lock, held by the shell like omarchy's: the time, the date and
a password field on every screen. It locks on `loginctl lock-session`, on
idle and before suspend, and checks the password through PAM.

For more context [lock](./lock.md)

## Status

The aggregate; each component doc carries its own detail and rough edges.

| Component | State                                                       |
| --------- | ----------------------------------------------------------- |
| Style     | Done. One `style.json`, per-component overrides verified    |
| Theme     | Done. Cascade matches omarchy on all 22; switching over IPC |
| Bar       | Seven widgets, styled; Sway and Hyprland behind one adapter   |
| Menu      | Options, command, project and bookmarks menus done          |
| VPN panel | Written; not yet checked on screen                          |
| Battery   | Panel written; not yet checked on screen                    |
| Audio     | Panel written; not yet checked on screen                    |
| Lock      | Lock and triggers tested headless; not yet used for real    |

Open, roughly in the order each blocks something:

- **Nothing launches the shell.** The Home Manager module installs the
  package and exports `SARISARINAMA_PATH`, and that is all: no user service,
  no `exec-once`. Whether the launch belongs here or in canaima's compositor
  config is undecided. Until then the shell is started by hand, see
  [development.md](./development.md).
- **Hyprland is written but never run.** The adapter is verified to detect
  the compositor and load the right backend, and `Hypr.qml` compiles, but it
  has never spoken to a real Hyprland. See [bar](./bar.md).
- **No layout has been looked at under a compositor.** The shell loads under
  Sway with no QML errors, but neither the bar's layout nor `style.bar.scale`
  has been checked on screen.
- **The rest of the omarchy palettes** are unported. The cascade is proven
  against all 22, so this is transcription, not design. See
  [themes](./themes.md).
- Three startup rough edges: the shell paints its QML defaults for a tick
  before the palette loads, the workspace list is empty for a tick before the
  compositor answers, and `ConfigFile` warns about `current.json` on every
  start although that file is meant to be absent until the first `theme set`.

## Prerequisites

Check [prerequisites.md](./prerequisites.md)

## Notes

`nvim-base` is one of the flavors of my `neovim` configuration [kukenan](https://github.com/juanalbarran/kukenan)
