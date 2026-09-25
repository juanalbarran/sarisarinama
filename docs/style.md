# Style

Geometry and typography of the UI, declared in Nix and read by the shell
from one file. Style never holds a color: colors are the theme's, see
[themes](./themes.md). The same split as omarchy's `Commons/Style.qml` and
`Commons/Color.qml`; their tokens live in `default/themed/shell.toml.tpl`,
which omanix renders from Nix in `lib/shell-toml.nix`. Omarchy keeps the
per-surface colors in that same template; sarisarinama keeps them beside
the palette, in `surfaces.json`.

## Contract (`~/.config/sarisarinama/style.json`)

One object: what every component shares, then a section per component.
Every key has a default in QML, so a missing file or key still works.

```json
{
  "font": { "family": "JetBrains Mono Nerd Font", "size": 12 },
  "spacing": { "scale": 1.0 },
  "menu": {
    "font": { "family": null, "size": null },
    "scale": null,
    "card": { "width": 300, "padding": 18, "radius": 8, "border": 1 },
    "row": { "height": 36, "paddingX": 12 }
  },
  "bar": { "…": "one block per widget, see bar.md" }
}
```

## Inheriting, and overriding

Every component carries the shared keys again: `font.family`, `font.size`
and `scale`. `null`, the default, means "take the shared one". A value
replaces it for that component alone, so the menu can be set in 18px
without touching the bar.

`scale` sits at the top of a component, not under `spacing`, because
`style.bar.spacing` is already the gap between widgets and a component's
own keys win the merge. The options come from `_lib/shared.nix`, one
helper for every component.

## Rules, never declared

- Each component has its own type scale, rooted at its `font.size`:
  caption ×0.833, body ×1, title ×1.167, heading ×1.333. A widget names a
  step; `fontSize` overrides it with px.
- `Style.space(px)` scales a design pixel by the _shared_ scale, never
  below 1. Section tokens arrive scaled, so it is only for literals left
  in QML.
- Radius and border are strokes, not spaces, and are never scaled.
- Menu row height is the larger of `row.height` and the menu's own body
  size + 2×`row.paddingX`, so raising the font raises the row.
- Card height is padding, title, gap and rows, capped at 70% of the screen.

## Files

| File                               | Role                                       |
| ---------------------------------- | ------------------------------------------ |
| `quickshell/theme/Style.qml`       | Singleton; shared tokens, one per section  |
| `quickshell/theme/FontScale.qml`   | One family, one size, the four steps       |
| `quickshell/theme/BarStyle.qml`    | The bar section, with its defaults         |
| `quickshell/theme/MenuStyle.qml`   | The menu section, with its defaults        |
| `quickshell/theme/ConfigFile.qml`  | Watched FileView; `{}` on error; theme too |
| `quickshell/theme/qmldir`          | Registers every singleton of `theme/`      |
| `modules/ui/style/options.nix`     | `style.font` and `style.spacing`           |
| `modules/ui/style/_lib/shared.nix` | The keys a component may override          |
| `modules/ui/style/bar.nix`         | `style.bar.*`, one block per widget        |
| `modules/ui/style/menu.nix`        | `style.menu.*`                             |
| `modules/ui/style/render.nix`      | Writes `sarisarinama/style.json`           |

`modules/preview.nix` collects every `xdg.configFile`, so `style.json`
appears in `nix build .#menus` without changes there. It is also the one
place this repo sets an option, so it is where to try a value before it
goes in the real config. Radius and gaps are declared here, not read from
`hyprctl`: the shell also runs under Sway.

## Status

Done. No component reads past its own section: `grep "Style.font"` outside
`quickshell/theme/` returns nothing. Overrides verified at runtime — menu
at Fira Code 18 ×1.5 gives a 54px row while the bar stays at 12.
`style.bar.scale` resolves but its layout has not been tried under a
compositor.

Colors were the open question here, and [themes](./themes.md) answers it:
their own module, and their own files, `themes/<name>.json` and
`surfaces.json`, never `style.json`.
