# Sarisarinama

The goal here is to create an ui with a `quickshell` instance, for reference check [omanix](https://github.com/T00fy/omanix) or [omarchy](https://github.com/omacom/omarchy/tree/quattro)
This is gonna work as a `flake` that will be inserted into my `NixOS` configuration [canaima](https://github.com/juanalbarran/canaima)
Sarisarinama will be configured as a standalone flake and will use the `dendritic` pattern
The `window manager` `hyprland` or `sway` will auto launch the shell.

Everything the shell reads is declared in Nix and rendered to
`~/.config/sarisarinama/`: the menus, `style.json`, `surfaces.json` and one
file per theme. The QML never holds a literal — no font, no length, no
colour. How the flake is put together is [nix.md](./nix.md).

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
the entries when the menu opens. The project menu is still to write.

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

## Notes

`herdr` is a multiplexer
`nvim-base` is one of the flavors of my `neovim` configuration [kukenan](https://github.com/juanalbarran/kukenan)
