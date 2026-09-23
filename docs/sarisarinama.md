# Sarisarinama

The goal here is to create an ui with a `quickshell` instance, for reference check [omanix](https://github.com/T00fy/omanix) or [omarchy](https://github.com/omacom/omarchy/tree/quattro)
This is gonna work as a `flake` that will be inserted into my `NixOS` configuration [canaima](https://github.com/juanalbarran/canaima)
Sarisarinama will be configured as a standalone flake and will use the `dendritic` pattern
The `window manager` `hyprland` or `sway` will auto launch the shell.

## Testing Sarisarinama

The development loop — render the menus, symlink them into
`~/.config/sarisarinama/`, run the shell and toggle a menu over IPC — is in
[development.md](./development.md).

## Components

### Bar

The `bar` component is located at the bottom so it is easier to check the hour, it will contain the `workspaces` at the left and the services icons to the right

For more context [bar](./bar.md)

### Menu

The `menu` will be inspired in the omarchy `menu`, read the code and docs from omarchy quattro. Check [omanix](https://github.com/T00fy/omanix)
There are two kinds of menu: `options menu` and `project menu`
All the menus should contain an option to go back if it is open by another menu

For more context [menu](./menu.md)

### Themes

The `themes` components is in charge of setting the configuration of the look and feel of all the components in `sarisarinama` all the components should have an unified look and it will be set here in themes.

For more context [style](./style.md)

## Notes

`herdr` is a multiplexer
`nvim-base` is one of the flavors of my `neovim` configuration [kukenan](https://github.com/juanalbarran/kukenan)
