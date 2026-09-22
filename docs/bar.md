# Bar

The bar sits at the bottom so the clock is easy to check: workspaces on the
left, service icons on the right.

## Files (`quickshell/bar/`)

`Bar.qml` (PanelWindow), `Workspaces.qml`, `Clock.qml`, `Battery.qml`,
`Audio.qml`, `Network.qml`, `Tray.qml`. Components import `"../theme/"` for
colors; sibling files are imported implicitly.

## Status

- Works under Sway. `Workspaces.qml` imports `Quickshell.I3`; Hyprland needs
  `Quickshell.Hyprland` behind a runtime-selected adapter
  (`HYPRLAND_INSTANCE_SIGNATURE` vs `SWAYSOCK`).
- `modules/bar.nix` is empty. Bar options in Nix should follow the menu
  layout: `modules/ui/bar/`.
- Not re-tested since the shell became the single host.
