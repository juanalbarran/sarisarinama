# Bar

It sits at the bottom so the clock is easy to check: workspaces on the
left, the clock in the centre, service icons on the right.

## Files (`quickshell/bar/`)

`Bar.qml` is the PanelWindow, anchored to the bottom, left and right edges.
It lays out the widgets and imports them with `import "./widgets/"`;
nothing else in the tree imports that directory.

`widgets/` holds one self-contained element per file, each importing
`"../../theme/"` and knowing nothing about the window. `Workspaces.qml`
also imports `"../../compositor/"`; no widget imports a compositor module
directly.

| Widget           | Place  | Shows                                          | Does                            |
| ---------------- | ------ | ---------------------------------------------- | ------------------------------- |
| `Workspaces.qml` | left   | one icon per workspace: urgent, focused, empty | click switches to it            |
| `Clock.qml`      | centre | `HH:mm \| ddd, dd`, from `SystemClock`         | —                               |
| `Tray.qml`       | right  | `SystemTray` icons                             | click activates the item        |
| `Audio.qml`      | right  | default Pipewire sink: muted or 3 levels       | click mutes, wheel ±5%          |
| `Network.qml`    | right  | ethernet, wifi or disconnected                 | polls `nmcli` every 5 s         |
| `Battery.qml`    | right  | icon per decile + percent, charging bolt       | hidden without a laptop battery |

Adding one means dropping a file in `widgets/` and placing it in the left
row, the centre or the right row of `Bar.qml`. The file name is the type
name, so pick one no imported module exports. A `qmldir` here would hide
`Bar.qml` from `shell.qml`, so this directory has none.

## The compositor (`quickshell/compositor/`)

Sway and Hyprland disagree about workspaces in exactly two places: the
number is `num` on i3 and `id` on Hyprland, and switching to a workspace
that does not exist yet is `workspace number 3` against `workspace 3`.
Everything else the bar reads — `focused`, `urgent`, `activate()` — is
spelled the same on both, so it is passed through rather than copied. An
existing workspace is switched to with its own `activate()`; only a missing
one is dispatched by command, since it has no object to call.

`Compositor.qml` is the singleton. It reads `HYPRLAND_INSTANCE_SIGNATURE`,
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
`sourceComponent` would resolve the type at compile time and pull
`import Quickshell.Hyprland` on both compositors, sending the losing one
looking for a socket that is not there.

`Compositor.workspace(n)` returns the **live** workspace object, or null.
A binding re-runs only when a property it read itself changes, so an adapter
that flattened `{num, focused, urgent}` into a plain object would update
when a workspace appeared and never when focus moved. The caller reads
`.focused` and `.urgent` off the live object; that is what keeps it live.

`Hypr.qml` is named `Hypr` because a local file loses to a type of the same
name from an imported module, and `Quickshell.Hyprland` exports `Hyprland`.
Only `Compositor` is in the `qmldir`, so nothing else can reach a backend
and wake the wrong socket.

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
  "workspaces": { "step": "caption", "fontSize": null, "count": 5,
                  "spacing": 7, "paddingX": 2, "animation": 300 },
  "audio":      { "step": "body",    "fontSize": null },
  "battery":    { "step": "body",    "fontSize": null },
  "network":    { "step": "body",    "fontSize": null },
  "tray":       { "iconSize": 16, "spacing": 8 }
}
```

`paddingLeft` is the gap from the screen edge to the workspaces,
`paddingRight` from the last widget to the edge. `spacing` is the gap
between the widgets of the right row only; the workspaces bring their own.
The bar's length multiplier is `scale`, at the top. That collision is why
`scale` is not nested under `spacing`.

`count` is how many indicators are drawn, not how wide they are; like
`animation` it is read raw, never through `px()`, or a bar at scale 1.5
would grow from five workspaces to eight. See [style](./style.md).

A text-only widget needs no block in `BarStyle.qml`; it calls
`Style.bar.textSize("<widget>", "<step>")`. Only `workspaces` and `tray` do.

## Colors (the `bar` block of `surfaces.json`)

`background`, `backgroundAlpha`, `text`, `focused` (the focused workspace),
`hover` and `urgent` (an urgent workspace, a battery at 15% or less and not
charging). A widget reads `Colors.bar.<token>`, never a palette key. Which
key each token points at is [themes](./themes.md); the defaults in
`BarColors.qml` are tokyo-night's, so the bar still paints with no file.

## Status

- Styled: no font, length or color literal is left in the bar.
- Looks belong to the style module, so there is no `modules/ui/bar/`.
- Runs under both compositors. Detection and the Loader were checked each
  way from a Sway box, forcing the other branch with
  `HYPRLAND_INSTANCE_SIGNATURE=fake`: the right backend loads, and the
  warning about a missing Hyprland socket appears only when forced. That
  is how we know `Hypr.qml` is never compiled under Sway.
- Reactivity verified live: a binding over `Compositor.workspace(n)`
  fires on every `swaymsg workspace number N`.
- `Hypr.qml` compiles and instantiates but has never run against a real
  Hyprland. That `id` is the number a user sees, and that `workspace 3` is
  the right dispatch, are still taken on trust.
- The shell loads under Sway with no QML errors; the layout itself has not
  been eyeballed, and `style.bar.scale` has not been tried on screen.
- `Network.qml` shells out to `nmcli`, so it needs NetworkManager; without
  it the icon stays on "disconnected".

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
