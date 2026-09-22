# Bar

The bar sits at the bottom so the clock is easy to check: workspaces on the
left, service icons on the right.

## Files (`quickshell/bar/`)

`Bar.qml` is the PanelWindow. It lays out the widgets and imports them with
`import "./widgets/"`; nothing else in the tree imports that directory.

`widgets/` holds one self-contained element per file: `Workspaces.qml`,
`Clock.qml`, `Battery.qml`, `Audio.qml`, `Network.qml`, `Tray.qml`. Each
imports `"../../theme/"` for colors and knows nothing about the window.

Adding a widget means dropping a file in `widgets/` and placing it in one of
the three rows of `Bar.qml`. The file name is the type name, so pick one
that no imported module exports.

## Status

- Works under Sway. `Workspaces.qml` imports `Quickshell.I3`; Hyprland needs
  `Quickshell.Hyprland` behind a runtime-selected adapter
  (`HYPRLAND_INSTANCE_SIGNATURE` vs `SWAYSOCK`).
- `modules/bar.nix` is empty. Bar options in Nix should follow the menu
  layout: `modules/ui/bar/`.
- Not re-tested since the shell became the single host.
