# Bar

It sits at the bottom so the clock is easy to check: workspaces on the
left, service icons on the right.

## Files (`quickshell/bar/`)

`Bar.qml` is the PanelWindow. It lays out the widgets and imports them with
`import "./widgets/"`; nothing else in the tree imports that directory.

`widgets/` holds one self-contained element per file, each importing
`"../../theme/"` and knowing nothing about the window.

Adding one means dropping a file in `widgets/` and placing it in the left
row, the centre or the right row of `Bar.qml`. The file name is the type
name, so pick one no imported module exports. A `qmldir` here would hide
`Bar.qml` from `shell.qml`, so this directory has none.

## Tokens (the `bar` section of `style.json`)

Declared in `modules/ui/style/bar.nix`, read by `theme/BarStyle.qml`. Every
widget shares `font.family`; `step` names a step of the type scale, and
`fontSize` overrides it with px.

```json
"bar": {
  "height": 30, "paddingLeft": 40, "paddingRight": 20, "spacing": 10,
  "clock":      { "step": "title",   "fontSize": null },
  "workspaces": { "step": "caption", "fontSize": null, "spacing": 7,
                  "paddingX": 2, "animation": 300 },
  "audio":      { "step": "body",    "fontSize": null },
  "battery":    { "step": "body",    "fontSize": null },
  "network":    { "step": "body",    "fontSize": null },
  "tray":       { "iconSize": 16, "spacing": 8 }
}
```

A text-only widget needs no block in `BarStyle.qml`; it calls
`Style.bar.textSize("<widget>", "<step>")`. Only `workspaces` and `tray` do.

## Status

- Styled: no font or length literal is left in the bar.
- Looks belong to the style module, so there is no `modules/ui/bar/`.
- Works under Sway (`Quickshell.I3`). Hyprland needs `Quickshell.Hyprland`
  behind an adapter picked at runtime (`HYPRLAND_INSTANCE_SIGNATURE`).
- Bindings checked headlessly; layout not re-tested under a compositor.

## Directory structure

```
bar/
├── Bar.qml
└── widgets/
    ├── Audio.qml
    ├── Battery.qml
    ├── Clock.qml
    ├── Network.qml
    ├── Tray.qml
    └── Workspaces.qml
```
