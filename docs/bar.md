# Bar

It sits at the bottom so the clock is easy to check: workspaces on the
left, service icons on the right.

## Files (`quickshell/bar/`)

`Bar.qml` is the PanelWindow. It lays out the widgets and imports them with
`import "./widgets/"`; nothing else in the tree imports that di

`widgets/` holds one self-contained element per file, each impo
`"../../theme/"` and knowing nothing about the window. `Workspaces.qml`
also imports `"../../compositor/"`; no widget imports a composi
directly.

Adding one means dropping a file in `widgets/` and placing it in the left
row, the centre or the right row of `Bar.qml`. The file name is
name, so pick one no imported module exports. A `qmldir` here would hide
`Bar.qml` from `shell.qml`, so this directory has none.

## The compositor (`quickshell/compositor/`)

Sway and Hyprland disagree about workspaces in exactly two plac
number is `num` on i3 and `id` on Hyprland, and the switch is `workspace
number 3` against `workspace 3`. Everything else the bar reads
`urgent`, `activate()` — is spelled the same on both, so it is passed
through rather than copied.

`Compositor.qml` is the singleton. It reads `HYPRLAND*INSTANCE*
which Hyprland exports into every client it launches and Sway does not, and
loads one backend behind it.

| File             | Role                                           |
| ---------------- | ---------------------------------------------- |
| `qmldir`         | Registers `Compositor`, and nothing else       |
| `Compositor.qml` | Detects, loads one backend, forwards two calls |
| `Sway.qml`       | `Quickshell.I3`; workspaces by `num`           |
| `Hypr.qml`       | `Quickshell.Hyprland`; workspaces by `id`      |

Two rules hold this together.

The backend is loaded by **URL**, `source: "Hypr.qml"`, never as a type. A
`sourceComponent` would resolve the type at compile time and pr
`import Quickshell.Hyprland` on both compositors, sending the losing one
looking for a socket that is not there.

`Compositor.workspace(n)` returns the **live** workspace object
A binding re-runs only when a property it read itself changes, so an adapter
that flattened `{num, focused, urgent}` into a plain object wou
when a workspace appeared and never when focus moved. The caller reads
`.focused` and `.urgent` off the live object; that is what keep

`Hypr.qml` is named `Hypr` because a local file loses to a type
name from an imported module, and `Quickshell.Hyprland` exports `Hyprland`.
Only `Compositor` is in the `qmldir`, so nothing else can reach
and wake the wrong socket.

## Tokens (the `bar` section of `style.json`)

Declared in `modules/ui/style/bar.nix`, read by `theme/BarStyle.qml`. Every
widget shares the bar's own `font`, which is the shared one unl
overrides it; `step` names a step of that scale, and `fontSize` overrides
it with px. `scale` is the bar's length multiplier; `null` take
one. Both come from `_lib/shared.nix`, see [style](./style.md).

```json
"bar": {
  "font": { "family": null, "size": null }, "scale": null,
  "height": 30, "paddingLeft": 40, "paddingRight": 20, "spacing
  "clock":      { "step": "title",   "fontSize": null },
  "workspaces": { "step": "caption", "fontSize": null, "count":
                  "spacing": 7, "paddingX": 2, "animation": 300 },
  "audio":      { "step": "body",    "fontSize": null },
  "battery":    { "step": "body",    "fontSize": null },
  "network":    { "step": "body",    "fontSize": null },
  "tray":       { "iconSize": 16, "spacing": 8 }
}
```

`spacing` is the gap between widgets, in px; the bar's length multiplier is
`scale`, at the top. That collision is why `scale` is not neste

`count` is how many indicators are drawn, not how wide they are
`animation` it is read raw, never through `px()`, or a bar at scale 1.5
would grow from five workspaces to eight. See [style](./style.m

A text-only widget needs no block in `BarStyle.qml`; it calls
`Style.bar.textSize("<widget>", "<step>")`. Only `workspaces` and `tray` do.

## Colors (the `bar` block of `surfaces.json`)

`background`, `text`, `focused` (the focused workspace), `hover` and
`urgent`. A widget reads `Colors.bar.<token>`, never a palette
key each token points at is [themes](./themes.md).

## Status

- Styled: no font, length or color literal is left in the bar.
- Looks belong to the style module, so there is no `modules/ui/
- Runs under both compositors. Detection and the Loader were checked each
  way from a Sway box, forcing the other branch with
  `HYPRLAND_INSTANCE_SIGNATURE=fake`: the right backend loads, and the
  warning about a missing Hyprland socket appears only when for
  is how we know `Hypr.qml` is never compiled under Sway.
- Reactivity verified live: a binding over `Compositor.workspac
fires on every `swaymsg workspace number N`.
- `Hypr.qml` compiles and instantiates but has never run agains
  Hyprland. That `id` is the number a user sees, and that `workspace 3` is
  the right dispatch, are still taken on trust.
- The shell loads under Sway with no QML errors; the layout itself has not
  been eyeballed, and `style.bar.scale` has not been tried on o

## Directory structure

```
bar/                    compositor/
├── Bar.qml             ├── Compositor.qml
└── widgets/            ├── Hypr.qml
    ├── Audio.qml       ├── Sway.qml
    ├── Battery.qml     └── qmldir
    ├── Clock.qml
    ├── Network.qml
    ├── Tray.qml
    └── Workspaces.qml
```
