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
widget shares the bar's own `font`, which is the shared one unless the bar
overrides it; `step` names a step of that scale, and `fontSize` overrides
it with px. `scale` is the bar's length multiplier; `null` takes the shared
one. Both come from `_lib/shared.nix`, see [style](./style.md).

```json
"bar": {
  "font": { "family": null, "size": null }, "scale": null,
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

`spacing` is the gap between widgets, in px; the bar's length multiplier is
`scale`, at the top. That collision is why `scale` is not nested.

A text-only widget needs no block in `BarStyle.qml`; it calls
`Style.bar.textSize("<widget>", "<step>")`. Only `workspaces` and `tray` do.

## Colors (the `bar` block of `surfaces.json`)

`background`, `text`, `focused` (the focused workspace), `hover` and
`urgent`. A widget reads `Colors.bar.<token>`, never a palette key; which
key each token points at is [themes](./themes.md).

## Status

- Styled: no font, length or color literal is left in the bar.
- Looks belong to the style module, so there is no `modules/ui/bar/`.
- Works under Sway (`Quickshell.I3`). Hyprland needs `Quickshell.Hyprland`
  behind an adapter picked at runtime (`HYPRLAND_INSTANCE_SIGNATURE`).
- Bindings checked headlessly; layout not re-tested under a compositor.
- `style.bar.scale` resolves but has not been tried on a real layout.

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
