# Style

Geometry and typography of the UI, declared in Nix and read by the shell
from one file. Colors stay in `Colors.qml` (later `colors.json`); style
never holds a color. The same split as omarchy's `Commons/Style.qml` and
`Commons/Color.qml`; their tokens live in `default/themed/shell.toml.tpl`,
omanix renders that file from Nix in `lib/shell-toml.nix`.

## Contract (`~/.config/sarisarinama/style.json`)

One object: what every component shares, then a section per component.
Every key has a default in QML, so a missing file or key still works.

```json
{
  "font": { "family": "JetBrains Mono Nerd Font", "size": 12 },
  "spacing": { "scale": 1.0 },
  "menu": {
    "card": { "width": 300, "padding": 18, "radius": 8, "border": 1 },
    "row": { "height": 36, "paddingX": 12 }
  },
  "bar": { "…": "one block per widget, see bar.md" }
}
```

Rules, never declared:

- Type scale from `font.size`: caption ×0.833, body ×1, title ×1.167,
  heading ×1.333. A widget names a step; `fontSize` overrides it with px.
- `Style.space(px)` scales a design pixel, never below 1. Section tokens
  arrive scaled, so it is only for literals left in QML.
- Radius and border are strokes, not spaces, and are never scaled.
- Menu row height is the larger of `row.height` and body + 2×`row.paddingX`.
- Card height is padding, title, gap and rows, capped at 70% of the screen.

## Files

| File                              | Role                                             |
| --------------------------------- | ------------------------------------------------ |
| `quickshell/theme/Style.qml`      | Singleton; shared tokens, one object per section |
| `quickshell/theme/BarStyle.qml`   | The `bar` section, with its defaults             |
| `quickshell/theme/MenuStyle.qml`  | The `menu` section, with its defaults            |
| `quickshell/theme/ConfigFile.qml` | Watched FileView; `{}` on error                  |
| `quickshell/theme/qmldir`         | Registers both singletons and both types         |
| `modules/ui/style/options.nix`    | `font` and `spacing`                             |
| `modules/ui/style/bar.nix`        | `style.bar.*`, one block per widget              |
| `modules/ui/style/menu.nix`       | `style.menu.*`                                   |
| `modules/ui/style/render.nix`     | Writes `sarisarinama/style.json`                 |

`preview.nix` collects every `xdg.configFile`, so `style.json` appears in
`nix build .#menus` without changes there. Radius and gaps are declared
here, not read from `hyprctl`: the shell also runs under Sway.

## Status

Done. Menu and bar take every length and font from `style.json`; no font
literal is left in `quickshell/`.

Open: whether `Colors.qml` moves to a rendered `colors.json` in the same
module or in a separate `theme` module.
